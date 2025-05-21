# 使用 nssm 安装 syncthing 服务
# https://docs.syncthing.net/users/autostart.html#autostart-windows-taskschd

# Stop execution when something goes wrong
$ErrorActionPreference = "Stop"

# 环境变量在 sudo 时也要保证注入
Import-Module -Name "$env:DOTFILES\shell\pwsh\Modules\NssmHelper.psm1" -Force -DisableNameChecking

Require-Sudo $($MyInvocation.MyCommand.Path)

# 检查必要的命令和文件
$requiredCommands = @('syncthing', 'nssm')

# 检查命令
foreach ($cmd in $requiredCommands) {
    Assert-CommandExists $cmd
}

# 获取命令路径
$syncthingPath = Get-CommandPath 'syncthing'
$nssmPath = Get-CommandPath 'nssm'

# 设置服务名称
$serviceName = 'syncthing'

# 检查服务是否存在
Remove-ExistingService $serviceName

# 安装服务
try {
    # 使用 NSSM 安装服务
    & $nssmPath install $serviceName $syncthingPath "--no-restart" "--no-browser"

    # 设置服务属性
    # https://nssm.cc/commands
    $nssmSettings = @{
        DisplayName     = "Syncthing Service [managed by nssm]"
        Description     = "Syncthing is a continuous file synchronization program."
        Start           = "SERVICE_DELAYED_AUTO_START"
        DependOnService = "Tcpip"
        AppDirectory    = $PSScriptRoot
        AppNoConsole    = "1"
    }

    foreach ($setting in $nssmSettings.GetEnumerator()) {
        & $nssmPath set $serviceName $setting.Key $setting.Value
    }

    # 根据文档为处理重启更新行为需要额外设置的属性
    # https://docs.syncthing.net/users/autostart.html#autostart-windows-taskschd
    & $nssmPath set $serviceName AppExit Default Exit
    & $nssmPath set $serviceName AppExit 0 Exit
    & $nssmPath set $serviceName AppExit 3 Restart
    & $nssmPath set $serviceName AppExit 4 Restart

    # 启动服务
    Start-Service -Name $serviceName

    Write-Host "$($serviceName) 服务已成功安装并启动！" -ForegroundColor Green
} catch {
    Write-Error "安装或配置服务时出错：$_"
    exit 1
}
