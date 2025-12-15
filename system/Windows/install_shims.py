# -*- coding: utf-8 -*-
import argparse
import os
import pathlib
import subprocess
import sys
import urllib.request

# 兼容 Python 3.11 之前的版本
try:
    import tomllib
except ImportError:
    print("错误：此脚本需要 Python 3.11 或更高版本，或者安装了 'tomli' 库。")
    sys.exit(1)


# 控制台颜色
class Color:
    GREEN = "\033[92m"
    CYAN = "\033[96m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    RESET = "\033[0m"


def write_success(message):
    print(f"{Color.GREEN}✓ {message}{Color.RESET}")


def write_progress(message):
    print(f"{Color.CYAN}→ {message}{Color.RESET}")


def write_info(message):
    print(f"{Color.YELLOW}! {message}{Color.RESET}")


def write_error(message):
    print(f"{Color.RED}✗ {message}{Color.RESET}")


def expand_path(path_str):
    """展开路径中的 ~ 和环境变量"""
    return pathlib.Path(os.path.expandvars(os.path.expanduser(path_str)))


def get_shim_executable(target_path, github_repo):
    """检查并下载 shim_exec.exe"""
    if target_path.exists():
        write_success("shim_exec.exe 已存在")
        return

    write_progress("正在下载 shim_exec.exe...")
    target_path.parent.mkdir(parents=True, exist_ok=True)

    download_url = (
        f"https://wget.la/github.com/{github_repo}/releases/latest/download/shim_exec.exe"
    )
    try:
        urllib.request.urlretrieve(download_url, target_path)
        write_success("shim_exec.exe 下载完成")
    except Exception as e:
        write_error(f"下载 shim_exec.exe 失败: {e}")
        sys.exit(1)


def remove_existing(target):
    """如果目标存在，则移除"""
    if target.exists() or target.is_symlink():
        try:
            if target.is_dir() and not target.is_symlink():
                os.rmdir(target)
            else:
                os.remove(target)
            return True
        except OSError as e:
            write_error(f"移除现有目标 '{target}' 失败: {e}")
            return False
    return True


def create_shim(source, target, shim_exec_path, args_dict, debug):
    """创建单个 shim"""
    write_progress(f"正在创建 shim: {source}")
    target.parent.mkdir(parents=True, exist_ok=True)

    if not remove_existing(target):
        return

    cmd = [
        str(shim_exec_path),
        "--path", str(source),
        "--output", str(target),
    ]

    args_dict = args_dict or {}
    if args_dict.get("args"):
        cmd.extend(["--command", " ".join(args_dict["args"])])
    if args_dict.get("type"):
        cmd.append(f"--{args_dict['type'].lower()}")
    if debug:
        cmd.append("--debug")

    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        write_success(f"成功创建 shim: {target}")
    except subprocess.CalledProcessError as e:
        if "SHIM_EXEC has successfully created" in e.stderr:
            write_success(e.stderr.rstrip())
        else:
            write_error(f"创建 shim 失败: {e}\n{e.stderr}")


def create_symbolic_link(source, target):
    """创建符号链接"""
    write_progress(f"正在创建符号链接: {source}")
    target.parent.mkdir(parents=True, exist_ok=True)

    if not remove_existing(target):
        return

    try:
        os.symlink(source, target)
        write_success(f"成功创建符号链接: {target}")
    except OSError as e:
        write_error(f"创建符号链接失败: {e}")
        write_info("在 Windows 上创建符号链接通常需要管理员权限或已启用开发者模式。")
    except Exception as e:
        write_error(f"创建符号链接时发生未知错误: {e}")


def create_hard_link(source, target):
    """创建硬链接"""
    write_progress(f"正在创建硬链接: {source}")
    target.parent.mkdir(parents=True, exist_ok=True)

    if not remove_existing(target):
        return

    try:
        os.link(source, target)
        write_success(f"成功创建硬链接: {target}")
    except Exception as e:
        write_error(f"创建硬链接时发生未知错误: {e}")


def process_individuals(individuals, creation_func, **extra_args):
    """处理独立条目"""
    for item in individuals or []:
        source_path = expand_path(item["source"])
        target_path = expand_path(item["target"])

        if not source_path.exists():
            write_info(f"源文件不存在，跳过: {source_path}")
            continue

        if item["target"].endswith(("/", "\\")):
            target_path = target_path / source_path.name

        # 传递 shim 特有的参数
        shim_args = {
            "args_dict": {"args": item.get("args"), "type": item.get("type")}
        } if creation_func == create_shim else {}

        creation_func(source_path, target_path, **extra_args, **shim_args)


def process_groups(groups, creation_func, **extra_args):
    """处理分组条目，将其转换为独立条目后处理"""
    individuals = []
    for group in groups or []:
        for source_str in group["sources"]:
            individuals.append({
                "source": source_str,
                "target": group["target"]
            })
    process_individuals(individuals, creation_func, **extra_args)


def main():
    parser = argparse.ArgumentParser(
        description="使用 jphibert/shim_executable 安装 shims。",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "--debug", action="store_true", help="启用调试模式，显示详细信息"
    )
    args = parser.parse_args()

    config_path = pathlib.Path(__file__).parent / "install-shims-config.toml"
    if not config_path.exists():
        write_error(f"配置文件未找到: {config_path}")
        sys.exit(1)

    with open(config_path, "rb") as f:
        config = tomllib.load(f)

    # 确定并获取 shim generator
    shim_repo = config.get("shim_repository", "jphilbert/shim_executable")
    shim_exec_path = expand_path(config["shim_generator_path"])
    get_shim_executable(shim_exec_path, shim_repo)

    shim_extra_args = {"shim_exec_path": shim_exec_path, "debug": args.debug}

    process_groups(config.get("shim_groups"), create_shim, **shim_extra_args)
    process_individuals(config.get("shims"), create_shim, **shim_extra_args)
    process_groups(config.get("symbolic_link_groups"), create_symbolic_link)
    process_individuals(config.get("symbolic_links"), create_symbolic_link)
    process_groups(config.get("hard_link_groups"), create_hard_link)
    process_individuals(config.get("hard_links"), create_hard_link)


if __name__ == "__main__":
    main()
