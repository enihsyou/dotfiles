# 本文件导出环境变量

$env:HF_ENDPOINT = "https://hf-mirror.com"

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
