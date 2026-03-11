# 本文件导出环境变量

$env:HF_ENDPOINT = "https://hf-mirror.com"

$env:EDITOR = "vim"
# vscode 的自动保存会影响 git rebase
#$env:VISUAL = "code"

# 先禁用了看看哪里会出问题，或许是 git-delta
#$env:PAGER = 'less.exe'

# enable goup functionality on shell
# https://github.com/owenthereal/goup/
# 因为由 vfox 管理，所以禁用了
#$env:PATH += ";$HOME\.go\current\bin"

# redirect fnm_multishell directory
# https://github.com/Schniz/fnm/issues/696#issuecomment-2768555244
# 因为切换到 vfox，所以禁用了
#$env:XDG_RUNTIME_DIR = "$env:TEMP"

# https://yazi-rs.github.io/docs/installation/#windows
$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"

# FZF settings
$env:FZF_DEFAULT_COMMAND = "fd --type file --hidden --exclude .git"
# AUTODARKMODE is set by gui-app/AutoDarkMode
$env:FZF_DEFAULT_OPTS = "--color $env:AUTODARKMODE"

# 极致加速 oh-my-posh 启动，依赖于魔改版的 go.exe，提速 20ms，见 Obsidian 笔记
# 因为用了软链接而不是 shim，所以需要设置 GOROOT 才能让 go 正常运行
# 终端上这里指向 vfox 管理的 golang 版本，它肯定存在；IDE 就自行管理。
$env:GOROOT = "C:\Users\enihsyou\.version-fox\cache\golang\current"

# 使用类似 Linux 的命令行参数传递方式，避免传递给 .cmd 脚本用引号包起来的参数被解引号
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Function')]
$PSNativeCommandArgumentPassing = "Standard"

# Rust 镜像设置，参考 https://rsproxy.cn/
$env:RUSTUP_DIST_SERVER="https://rsproxy.cn"
$env:RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

# pprof 临时文件目录，远离系统盘
$env:PPROF_TMPDIR = "$env:TEMP/pprof"

# 检测当前 Windows 系统是否处于浅色模式
$themeRegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$env:AppUseLightTheme = ( Get-ItemProperty -Path $themeRegistryPath -ErrorAction SilentlyContinue ).AppsUseLightTheme ?? 0
