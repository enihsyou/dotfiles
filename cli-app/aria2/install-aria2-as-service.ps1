# 使用 nssm 安装 aria2 服务

# 函数：检查命令是否可用
function Test-CommandAvailable {
    param (
        [string]$CommandName
    )
    return [bool](Get-Command -Name $CommandName -ErrorAction SilentlyContinue)
}

# 检查管理员权限
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $prompt_title = "需要管理员权限来安装服务。"
    $prompt_message = "是否以管理员权限重新运行本脚本？"
    $prompt_choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    if ($Host.UI.PromptForChoice($prompt_title, $prompt_message, $prompt_choices, 0) -ne 0) {
        Write-Host "已取消操作。"
        exit
    }

    Write-Host "正在使用 sudo 重新运行脚本..." -ForegroundColor Green
    $cmd = @(
        "& `"$($MyInvocation.MyCommand.Path)`"",
        "pause"
    )   
    $arguments = @(
        '-NoProfile',
        '-EncodedCommand', [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd -join ';'))
    )
    # https://gist.github.com/mklement0/f726dee9f0d3d444bf58cb81fda57884
    $psExePath = (Get-Process -Id $PID).Path

    # if sudo is available, use sudo
    if (Test-CommandAvailable 'sudo') {
        sudo $psExePath $arguments
    } else {
        Start-Process -Verb RunAs -FilePath $psExePath -ArgumentList $arguments
    }
    exit
}

# 函数：获取命令的完整路径
function Get-CommandPath {
    param (
        [string]$CommandName
    )
    $command = Get-Command -Name $CommandName -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }
    return $null
}


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
    if (-not (Test-CommandAvailable $cmd)) {
        Write-Error "错误：在系统 PATH 中找不到 $cmd"
        exit 1
    }
}

# 检查文件
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file.Path)) {
        Write-Error "错误：找不到 $($file.Name)"
        exit 1
    }
}

# 获取命令路径
$aria2Path = Get-CommandPath 'aria2c'
$nssmPath = Get-CommandPath 'nssm'

# 设置服务名称
$serviceName = 'aria2'

# 检查服务是否存在
try {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        $prompt_title = "服务 $serviceName 已存在！"
        $prompt_message = "是否删除现有服务并重新安装？"
        $prompt_choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
        if ($Host.UI.PromptForChoice($prompt_title, $prompt_message, $prompt_choices, 1) -ne 0) {
            Write-Host "已取消操作。"
            exit 1
        }
        Write-Host "正在停止现有服务..."
        & $nssmPath stop $serviceName confirm
        Write-Host "正在删除现有服务..."
        & $nssmPath remove $serviceName confirm
        Write-Host "已发送指令，等待生效..." -NoNewline
        while ($null -ne (Get-Service -Name $serviceName -ErrorAction SilentlyContinue)) {  
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 1
        }
        Write-Host "服务已删除。" -ForegroundColor Green
    }
}
catch {
    Write-Error "检查服务状态时出错：$_"
    exit 1
}

# 安装服务
try {
    # 使用 NSSM 安装服务
    & $nssmPath install $serviceName $aria2Path "--conf-path=$($requiredFiles[0].Path)"

    # 设置服务属性
    $nssmSettings = @{
        Description     = "Aria2 Download Service [managed by nssm]"
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

    Write-Host "Aria2 服务已成功安装并启动！" -ForegroundColor Green
}
catch {
    Write-Error "安装或配置服务时出错：$_"
    exit 1
} 