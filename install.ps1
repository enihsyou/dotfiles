# Usage:
#  .\install.ps1        # 根据当前操作系统选择配置文件
#  .\install.ps1 <yaml> # 使用指定配置文件

# 代码核心来自 https://github.com/anishathalye/dotbot/blob/master/tools/git-submodule/install.ps1

$DOTBOT_DIR = "dotbot"
$DOTBOT_BIN = "bin/dotbot"
$BASEDIR = $PSScriptRoot

$CONFIG_PROFILES = @()

# 检查参数是否存在对应的配置文件，允许一定程度的简写和猜测，如果存在则添加到配置列表中
# 参数：
#   $1 - profile 名称 (例如: "linux", "macos") 或文件路径
# 返回值：
#   无返回值，但会修改全局变量 CONFIG_PROFILES
Function Add-Profile {
    param (
        [string]$1
    )
    $profile_file = $1
    if (Test-Path -Path $profile_file -PathType Leaf) {
        $script:CONFIG_PROFILES += $profile_file
        return
    }

    $guessed_file = "profile/dotbot-$1.yaml"
    if (Test-Path -Path $guessed_file -PathType Leaf) {
        $script:CONFIG_PROFILES += $guessed_file
        return
    }
}

if ($Args.Count -gt 0) {
    # 有参时使用指定配置文件
    foreach ($pArg in $Args) {
        Add-Profile $pArg
    }
} else {
    # 无参时根据操作系统选择配置文件

    # the IsWindows/IsMacOs/IsLinux variables are not present in powershell 5 and lower
    if (!(Test-Path Variable:\IsWindows) -or $IsWindows) {
        Add-Profile "windows"
    }
}

if ($CONFIG_PROFILES.Length -eq 0) {
    Write-Error "No profile file activated, please specify one or check your system."
    exit 1
}

$PYTHON = $null
foreach ($py in @("python", "python3")) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (& $py -V) {
        $PYTHON = $py
        break
    }
}
if (-not $PYTHON) {
    Write-Error "Error: Cannot find Python."
    exit 1
}

# 初始化 dotbot
Set-Location $BASEDIR
git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --remote --recursive $DOTBOT_DIR

# 依照选定的配置文件运行
foreach ($conf in $CONFIG_PROFILES) {
    Write-Output "Running dotbot with config: $conf"
    &$PYTHON (Join-Path (Join-Path $BASEDIR $DOTBOT_DIR) $DOTBOT_BIN) -d $BASEDIR -c $conf
}
