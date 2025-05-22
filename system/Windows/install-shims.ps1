# 根据 shims-list.json 的指令使用 jphibert/shim_exetuable 在特定目录部署 shims

param(
    [switch]$Debug,
    [switch]$Help
)

# 显示帮助信息
if ($Help) {
    Write-Host @'
使用 jphibert/shim_executable 安装 shims。用于把散落在各处的单个可执行文件，
收集到一个已添加到 PATH 环境变量的目录中，供终端调用。

用法: install-shims.ps1 [参数]

参数:
    --help             显示此帮助信息
    --debug            启用调试模式，显示详细信息

配置文件说明:
    配置文件名为 install-shims-config.jsonc，需要包含以下字段:
    - shim_generator_path: shim_exec.exe 的安装路径
    - shims: shim 配置数组，每个 shim 需要包含:
      * source: 源可执行文件路径
      * target: 目标 shim 路径
      * args: (可选) 传递给源程序的参数数组
      * type: (可选) shim 类型，可选值: "console" 或 "gui"

示例:
    {
        "shim_generator_path": "$HOME/.local/bin/shim_exec.exe",
        "shims": [
            {
                "source": "$HOME/AppData/Local/Programs/hurl/hurl.exe",
                "target": "$HOME/.local/bin/hurl.exe",
                "args": ["-m"],
                "type": "console"
            }
        ]
    }

注意:
    - 支持环境变量替换，如 $HOME, $TMP, $USERPROFILE
    - 如果 target 以斜杠结尾，会自动使用 source 的文件名
'@
    exit 0
}

# 设置错误操作
$ErrorActionPreference = "Stop"

# 输出函数
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Progress {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# 转换为 Windows 标准路径格式
function Convert-ToWindowsPath {
    param(
        [string]$Path
    )
    # 将正斜杠替换为反斜杠
    $Path = $Path.Replace('/', '\')
    # 处理双反斜杠
    $Path = $Path.Replace('\\', '\')
    # 处理特殊字符
    $Path = [System.IO.Path]::GetFullPath($Path)
    return $Path
}

# 检查并下载 shim_exec.exe
function Get-ShimExecutable {
    param(
        [string]$TargetPath,
        [string]$GitHubRepo
    )

    $TargetPath = Convert-ToWindowsPath $TargetPath

    if (Test-Path $TargetPath) {
        Write-Success "shim_exec.exe 已存在"
        return
    }

    Write-Progress "正在下载 shim_exec.exe..."

    # 创建目标目录
    $targetDir = Split-Path -Parent $TargetPath
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # 下载
    $downloadUrl = "https://github.com/$GitHubRepo/releases/latest/download/shim_exec.exe"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $TargetPath

    Write-Success "shim_exec.exe 下载完成"
}

# 安全的环境变量展开
function Expand-Variables {
    param(
        [string]$string
    )
    # 只允许 $ 开头的变量替换
    $pattern = '\$([a-zA-Z0-9_]+)'
    $result = $string
    $founds = [regex]::Matches($string, $pattern)

    foreach ($found in $founds) {
        $varName = $found.Groups[1].Value
        if ($varName -eq "HOME") {
            $result = $result.Replace($found.Value, $HOME)
            continue
        }
        $varValue = [System.Environment]::GetEnvironmentVariable($varName)
        if ($varValue) {
            $result = $result.Replace($found.Value, $varValue)
            continue
        }
        Write-Error "未找到变量: $varName"
        exit 1
    }

    return $result
}

# 验证 JSON 配置
function Test-Config {
    param(
        [object]$Config
    )

    # 检查必要字段
    $requiredFields = @('shim_generator_path')
    foreach ($field in $requiredFields) {
        if (-not $Config.PSObject.Properties.Name.Contains($field)) {
            Write-Error "配置文件缺少必要字段: $field"
            exit 1
        }
    }

    # 检查每个 shim 的必要字段
    foreach ($shim in $Config.shims) {
        if (-not $shim.source) {
            Write-Error "shim 配置缺少必要字段: source"
            exit 1
        }
        if (-not $shim.target) {
            Write-Error "shim 配置缺少必要字段: target"
            exit 1
        }
    }
}

# 创建单个 shim
function Create-Shim {
    param(
        [string]$Source,
        [string]$Target,
        [string]$ShimExecPath,
        [string[]]$Args,
        [string]$Type
    )

    Write-Host
    Write-Progress "正在创建 shim: $Source"

    # 创建目标目录
    $targetDir = Split-Path -Parent $Target
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # 构建命令
    $cmdArgs = @(
        "--path", $Source,
        "--output", $Target
    )

    # 添加可选参数
    if ($Args) {
        $cmdArgs += "--command", ($Args -join " ")
    }
    if ($Type) {
        $cmdArgs += "--$($Type.ToLower())"
    }
    if ($Debug) {
        $cmdArgs += "--debug"
    }

    # 执行命令
    try {
        & $ShimExecPath @cmdArgs
        Write-Success "成功创建 shim: $Target"
        return $true
    } catch {
        Write-Error "创建 shim 失败: $_"
        return $false
    }
}

# 创建符号链接
function Create-SymbolicLink {
    param(
        [string]$Source,
        [string]$Target
    )

    Write-Host
    Write-Progress "正在创建符号链接: $Source"

    # 创建目标目录
    $targetDir = Split-Path -Parent $Target
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # 检查目标是否已存在
    if (Test-Path $Target) {
        # 检查是否已经是正确的链接
        $existingLink = Get-Item $Target
        if ($existingLink.LinkType -eq "SymbolicLink" -and $existingLink.Target -eq $Source) {
            Write-Success "现有符号链接正确: $Target"
            return
        } else {
            Write-Info "目标文件之前指向: $($existingLink.Target)"
        }
    }

    # 创建符号链接
    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        Write-Success "成功创建符号链接: $Target"
    } catch {
        Write-Error "创建符号链接失败: $_"
    }
}

# 主函数
function Install-Shims {
    # 读取配置文件
    $supportConfigFiles = @(
        'install-shims-config.json',
        'install-shims-config.jsonc'
    )
    foreach ($configFile in $supportConfigFiles) {
        $configPath = Join-Path $PSScriptRoot $configFile
        if (-not (Test-Path $configPath)) {
            continue
        }

        $config = Get-Content $configPath | ConvertFrom-Json
        break
    }
    if (-not $config) {
        Write-Error "未找到配置文件"
        exit 1
    }

    # 验证配置
    Test-Config -Config $config

    # 检查并下载 shim_exec.exe
    # 确定 shim_generator_path，如果为空，使用默认值
    if ($config.shim_repository) {
        $shimRepository = $config.shim_repository
    } else {
        $shimRepository = "jphilbert/shim_executable"
    }
    $shimExecPath = Convert-ToWindowsPath (Expand-Variables $config.shim_generator_path)
    Get-ShimExecutable -TargetPath $shimExecPath -GitHubRepo $shimRepository

    # 处理每个 shim
    foreach ($shim in $config.shims) {
        $source = Convert-ToWindowsPath (Expand-Variables $shim.source)
        $target = Convert-ToWindowsPath (Expand-Variables $shim.target)

        # 如果目标以斜杠结尾，添加源文件名
        if ($target.EndsWith("\")) {
            $target = Join-Path $target (Split-Path -Leaf $source)
        }

        Create-Shim -Source $source -Target $target -ShimExecPath $shimExecPath -Args $shim.args -Type $shim.type
    }

    # 处理符号链接
    foreach ($link in $config.symbolic_links) {
        $source = Convert-ToWindowsPath (Expand-Variables $link.source)
        $target = Convert-ToWindowsPath (Expand-Variables $link.target)

        # 如果目标以斜杠结尾，添加源文件名
        if ($target.EndsWith("\")) {
            $target = Join-Path $target (Split-Path -Leaf $source)
        }

        Create-SymbolicLink -Source $source -Target $target
    }
}

# 执行主函数
Install-Shims
