# enihsyou's dotfiles

<p style="text-align: center;">
  <a href="README.md">English</a> •
  <a href="README.zh-CN.md">简体中文 (Simplified Chinese)</a>
</p>

这是一个用来管理个人 dotfiles 的项目，适配了过去和现在用于开发的 Linux, Container, macOS, iPad 和 Windows 系统，也包含一些个人使用经验和魔法操作的记录。

## 如何使用

> 前置需求，安装了 Git 和 Python

`dotbot` 让一切变得更简单，我的意思是只需要三条命令。

```shell
git clone https://github.com/enihsyou/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install
```

如果在 Windows 上，需要使用 PowerShell 脚本。

```powershell
git clone https://github.com/enihsyou/dotfiles.git ~/.dotfiles
cd ~\.dotfiles
powershell -ExecutionPolicy Bypass -File install.ps1
```

## 如何开发

- 多数配置假设本项目放在 `~/.dotfiles` 目录下，纯文本的配置文件不一定能访问环境变量，所以最好遵守这个约定
- 一些文件由 `Makefile` 生成，并加入手动编辑

## 背景信息

对 dotfiles 管理工具我有一些要求：

- 能够在不同的系统上使用，主要是 Linux, macOS 和 Windows
- 能在编辑器里快速编辑并通过 Git 分享，目录布局清晰
- 不止管理 HOME 下的文件，还包括 CLI、GUI 程序以及一些经验配置
- 不要求 DRY，可读性胜过简洁性，文件内容所见即所得

最初的版本是 fork 自 [holman/dotfiles][4]，在比较了[多种][1]开源社区的实现方案后，
目前选择了 [dotbot][2] 作为 dotfiles 管理工具。

> 还了解到有 [chezmoi][3] 这个工具，但它的目录布局我很不喜欢，
> 它提供的额外功能如加密、动态模板、安装钩子我用不上；
> 反而功能清单里模板、终端补全、文件初始化完全是它软件设计带来的复杂性。
> 尽管它带来了灵活性和可重用性，但牺牲了可读性和可维护性

[1]: https://dotfiles.github.io/utilities/
[2]: https://github.com/anishathalye/dotbot
[3]: https://github.com/chezmoi/chezmoi
[4]: https://github.com/holman/dotfiles
