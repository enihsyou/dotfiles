# 使用 nssm 安装 aria2 服务

# Stop execution when something goes wrong
$ErrorActionPreference = "Stop"

# 环境变量在 sudo 时也要保证注入
Import-Module -Name "$env:DOTFILES\shell\pwsh\Modules\NssmHelper.psm1" -Force -DisableNameChecking

Require-Sudo $($MyInvocation.MyCommand.Path)

# 检查必要的命令和文件
$requiredCommands = @('aria2c', 'nssm')
$requiredFiles = @(
    @{
        Path = Join-Path $PSScriptRoot 'aria2.conf'
        Name = 'aria2.conf'
    }
)

# 检查命令
foreach ($cmd in $requiredCommands) {
    Assert-CommandExists $cmd
}

# 检查文件
foreach ($file in $requiredFiles) {
    Assert-FileExists $file.Path
}

# 获取命令路径
$aria2Path = Get-CommandPath 'aria2c'
$nssmPath = Get-CommandPath 'nssm'

# 设置服务名称
$serviceName = 'aria2'

# 检查服务是否存在
Remove-ExistingService $serviceName

# 安装服务
try {
    # 使用 NSSM 安装服务
    & $nssmPath install $serviceName $aria2Path "--conf-path=$($requiredFiles[0].Path)"

    # 设置服务属性
    # https://nssm.cc/commands
    $nssmSettings = @{
        DisplayName     = "Aria2 Download Service [managed by nssm]"
        Description     = "aria2 is a lightweight multi-protocol & multi-source, cross platform download utility operated in command-line. It supports HTTP/HTTPS, FTP, SFTP, BitTorrent and Metalink."
        Start           = "SERVICE_DELAYED_AUTO_START"
        DependOnService = "Tcpip"
        AppDirectory    = $PSScriptRoot
        AppNoConsole    = "1"
    }

    foreach ($setting in $nssmSettings.GetEnumerator()) {
        & $nssmPath set $serviceName $setting.Key $setting.Value
    }

    # 启动服务
    Start-Service -Name $serviceName

    Write-Host "$($serviceName) 服务已成功安装并启动！" -ForegroundColor Green
} catch {
    Write-Error "安装或配置服务时出错：$_"
    exit 1
}
