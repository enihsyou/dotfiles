#!/usr/bin/env python3
# 本脚本接受 pkgpath.typename 的输入并返回文件路径
# 传入 --editor 参数则在对应注册的编辑器中打开文件

import abc
import argparse
import json
import re
import subprocess
import typing
import dataclasses


@dataclasses.dataclass
class Wanted:
    """ 请求参数解析的结果 """
    pkgpath: str
    expr_id: str
    method: str

    def __str__(self) -> str:
        result = f'{self.pkgpath}.{self.expr_id}'
        if self.method:
            result += f'@{self.method}'
        return result


@dataclasses.dataclass
class GoPkg:
    """ go list 的结果 """
    pkgpath: str
    pkgdir: str
    rootdir: str
    gofiles: typing.List[str]


@dataclasses.dataclass
class Greped:
    """ grep 的结果 """
    filepath: str
    line_num: int
    char_pos: int


def go_list_pkgdir(pkgpaths):
    """ 获取包的文件系统路径 """
    cmd_line = ['go', 'list', '-e', '-json']
    cmd_line.extend(pkgpaths)

    cmd = subprocess.run(cmd_line, capture_output=True)
    stdout = cmd.stdout.decode().strip()  # 末尾有个换行符

    collected = {}
    buffer = []
    for line in stdout.splitlines():
        buffer.append(line)
        if line != '}':
            continue  # go list 输出的是格式化后的 json, 这里按行收集
        loaded, buffer = json.loads(''.join(buffer)), []
        if 'Error' in loaded:
            continue  # 说明有错误
        gopkg = GoPkg(
            pkgpath=loaded['ImportPath'],
            pkgdir=loaded['Dir'],
            rootdir=loaded['Root'],
            gofiles=loaded['GoFiles'],  # 没有包含 TestGoFiles 等
        )
        collected[gopkg.pkgpath] = gopkg
    return collected


class Editor:
    registered = {}

    # noinspection PyMethodOverriding
    # false-positive
    def __init_subclass__(cls, name):
        """ 记录有实现的编辑器 """
        Editor.registered[name] = cls

    @abc.abstractmethod
    def open(self, gopkg: GoPkg, greped: Greped):
        """ 打开文件并定位到指定行, 可选提供行号/字符位置/所属项目路径 """
        pass


class GolangEditor(Editor, name='goland'):

    def open(self, _: GoPkg, greped: Greped):
        # https://www.jetbrains.com/help/idea/opening-files-from-command-line.html#macos
        filepath, line_num, char_pos = dataclasses.astuple(greped)
        cmd_line = ['goland']
        if line_num:
            cmd_line.extend(['--line', f'{line_num}'])
        if char_pos:
            cmd_line.extend(['--column', f'{char_pos}'])
        cmd_line.append(filepath)
        subprocess.run(cmd_line)


class VisualStudioCode(Editor, name='vscode'):

    def open(self, gopkg: GoPkg, greped: Greped):
        # https://code.visualstudio.com/docs/editor/command-line
        filepath, line_num, char_pos = dataclasses.astuple(greped)
        cmd_line = ['code']
        if line_num and char_pos:
            cmd_line.extend(['--goto', f'{filepath}:{line_num}:{char_pos}'])
        elif line_num:
            cmd_line.extend(['--goto', f'{filepath}:{line_num}'])
        else:
            cmd_line.append(filepath)
        if gopkg.rootdir:
            cmd_line.append(gopkg.rootdir)
        print(cmd_line)
        subprocess.run(cmd_line)


class Greper:
    registered = {}

    # noinspection PyMethodOverriding
    # false-positive
    def __init_subclass__(cls, name):
        """ 记录实现的搜索器 """
        Greper.registered[name] = cls

    @abc.abstractmethod
    def grep(self, gopkg: GoPkg, wanted: Wanted) -> typing.List[Greped]:
        """ 搜索类型所在的文件和行号范围 """
        pass


class GnuGrep(Greper, name='grep'):

    def grep(self, gopkg: GoPkg, wanted: Wanted):
        grep_output = self.run_grep(gopkg, wanted)
        matches = self.parse_grep_output(grep_output)
        return matches

    @staticmethod
    def run_grep(gopkg, wanted):
        cmd_line = ['grep', '--line-number', '-H', '-E', '--null']
        if wanted.method:
            cmd_line.extend([
                '--regexp', fr'^func.+\b{wanted.expr_id}\b.+\b{wanted.method}\b'])
        else:
            cmd_line.extend([
                '--regexp', fr'^type {wanted.expr_id}\s'])
        cmd_line.append('--')
        cmd_line.extend([f'{gopkg.pkgdir}/{file}' for file in gopkg.gofiles])
        cmd = subprocess.run(cmd_line, capture_output=True)
        return cmd.stdout.decode()

    @staticmethod
    def parse_grep_output(stdout):
        matches = []
        pattern = re.compile(r'^(.+)\0(\d+):')
        for line in stdout.splitlines():
            matched = pattern.match(line)
            matched = matched.groups()
            matches.append(Greped(matched[0], int(matched[1]), 0))
        return matches


class RipGrep(Greper, name='rg'):

    def grep(self, gopkg: GoPkg, wanted: Wanted):
        rg_json = self.run_grep(gopkg.pkgdir, wanted)
        matches = self.parse_json_wire_format(rg_json)
        return matches

    @staticmethod
    def run_grep(pkgdir, wanted):
        cmd_line = ['rg', '--json']
        if wanted.method:
            cmd_line.extend([
                '--regexp', fr'^func.+\b{wanted.expr_id}\b.+\b{wanted.method}\b'])
        else:
            cmd_line.extend([
                '--regexp', fr'^type {wanted.expr_id}\s'])
        cmd_line.append('--type=go')  # 只考虑 go 文件
        cmd_line.append(pkgdir)
        cmd = subprocess.run(cmd_line, capture_output=True)
        return cmd.stdout.decode()

    @staticmethod
    def parse_json_wire_format(rg_json):
        # 定义在 https://docs.rs/grep-printer/0.1.7/grep_printer/struct.JSON.html#wire-format
        matches = []
        for rg_line in rg_json.splitlines():
            rg_load = json.loads(rg_line)
            if rg_load.get('type') != 'match':
                continue
            filepath = str(rg_load['data']['path']['text'])
            line_num = int(rg_load['data']['line_number'])
            char_pos = None
            for submatch in rg_load['data']['submatches']:
                char_pos = int(submatch['start'])
                break
            matches.append(Greped(filepath, line_num, char_pos))
        return matches


class Program:

    @staticmethod
    def boot(sys_args=None):
        parser = argparse.ArgumentParser(
            description='''定位Go类型定义, 默认输出文件路径

一些使用例子:
1. 输出 time.Time 定义在哪个文件
    %(prog)s time.Time
2. 在 goland 中定位到 New 函数的位置
    %(prog)s time.New --editor goland
3. 还能匹配方法, 甚至是非导出的
    %(prog)s time.Time@unixSec
4. 作为特殊用法，最后一个参数可以是任意字符串，会输出所有匹配格式的内容
    %(prog)s "p1: time.Time\\np2: time.Duration"

执行结果和退出值
如果没有找到, 会返回错误码 1,
如果找到多个结果, 会返回错误码 2, 并把所有结果输出到 stderr
''',
            usage='%(prog)s [options] reference',
            # 避免 epilog 自动缩起
            formatter_class=argparse.RawDescriptionHelpFormatter)
        parser.add_argument('--editor', choices=Editor.registered.keys(),
                            help='用指定编辑器中打开文件, 而不是输出文件路径')
        parser.add_argument('--greper', choices=Greper.registered.keys(), default='rg',
                            help='选用文件检索器')
        parser.add_argument('reference', type=str,
                            help='Go定义的引用，用 pkgpath.typename 表示类型, 用 pkgpath.typename@method 表示方法')

        args = parser.parse_args(sys_args)
        args_as_dict = vars(args)
        return Program(parser, **args_as_dict)

    def __init__(self, parser, editor, greper, reference):
        self.parser = parser
        self.editor = editor
        self.greper = greper
        self.wanted = []

        # 取所有 pkgpath.expr_id@method
        regex = r'([\w./]+)[.]([\w]+)(?:@([\w]+))?'
        for match in re.finditer(regex, reference):
            self.wanted.append(Wanted(*match.groups()))

    def main(self):
        # 因为 go list 比较慢 所以先把所有 pkgpath 的目录都找出来
        golist = go_list_pkgdir(set(expect.pkgpath for expect in self.wanted))
        for wanted in self.wanted:
            if wanted.pkgpath not in golist:
                self.parser.error(f'无法找到 {wanted} 所在的包')

        # 在目录下寻找定义 可能有多个 都收集起来
        greper = Greper.registered[self.greper]()
        greped = []
        for wanted in self.wanted:
            gopkg = golist[wanted.pkgpath]
            greps = greper.grep(gopkg, wanted)
            if not greps:
                self.parser.error(f'无法找到 {wanted} 所在文件')
            greped.extend(greps)

        # 输出每个结果 但只有第一个会在编辑器中打开
        for greps in greped:
            print(f'{greps.filepath}:{greps.line_num}')  # 这个在 IDE 中能创建超链接
        for wanted in (self.editor and self.wanted) or []:
            gopkg = golist[wanted.pkgpath]
            editor = Editor.registered[self.editor]()
            editor.open(gopkg, greped[0])
            break


if __name__ == '__main__':
    prog = Program.boot()
    prog.main()
    open("/Users/enihsyou/.bash_history")
