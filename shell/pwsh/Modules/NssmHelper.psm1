# PowerShell 模块：NssmHelper.psm1
# 这个模块用于在其他脚本中操作 NSSM (Non-Sucking Service Manager) 服务。

# 函数：检查命令是否可用
function Test-CommandAvailable {
    param (
        [string]$CommandName
    )
    return [bool](Get-Command -Name $CommandName -ErrorAction SilentlyContinue)
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

function Assert-CommandExists {
    param (
        [string]$CommandName
    )
    if (-not (Test-CommandAvailable $CommandName)) {
        throw "错误：在系统 PATH 中找不到 '$CommandName'。"
    }
}

function Assert-FileExists {
    param (
        [string]$FilePath
    )
    if (-not (Test-Path $FilePath)) {
        throw "错误：找不到文件 '$FilePath'。"
    }
}


# 检查管理员权限, 返回 true 代表有权限
function Test-AdminPrivileges {
    $isAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $isAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 向用户确认是否以管理员权限重新运行脚本，返回 true 代表用户选择是
function Prompt-ForAdminPrivileges {
    $promptTitle = "需要管理员权限来安装服务。"
    $promptMessage = "是否以管理员权限重新运行本脚本？"
    $promptChoices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    return $Host.UI.PromptForChoice($promptTitle, $promptMessage, $promptChoices, 0) -eq 0
}

function Restart-ScriptAsAdmin {
    param (
        [string]$CommandPath
    )
    $cmd = @(
        "& `"$CommandPath`"",
        "pause"
    )
    $arguments = @(
        '-NoProfile',
        '-EncodedCommand', [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd -join ';'))
    )
    $psExePath = (Get-Process -Id $PID).Path

    # 如果 sudo 可用，使用 sudo
    if (Test-CommandAvailable 'sudo') {
        sudo --preserve-env $psExePath $arguments
    } else {
        Start-Process -Verb RunAs -FilePath $psExePath -ArgumentList $arguments
    }
}
function Require-Sudo {
    param (
        [string]$CommandPath
    )
    if (-not (Test-AdminPrivileges)) {
        if (Prompt-ForAdminPrivileges) {
            Write-Host "正在使用 sudo 重新运行脚本..." -ForegroundColor Green
            Restart-ScriptAsAdmin $CommandPath
        } else {
            Write-Host "已取消操作。" -ForegroundColor Red
        }
        exit
    }
}

# 向用户确认是否删除现有服务，返回 true 代表用户选择是
function Prompt-ForServiceDeletion {
    param (
        [string]$ServiceName
    )
    $promptTitle = "服务 $ServiceName 已存在！"
    $promptMessage = "是否删除现有服务并重新安装？"
    $promptChoices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    return $Host.UI.PromptForChoice($promptTitle, $promptMessage, $promptChoices, 0) -eq 0
}

function Remove-ExistingService {
    param (
        [string]$ServiceName
    )
    $nssmPath = Get-CommandPath 'nssm'
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            if (-not (Prompt-ForServiceDeletion $ServiceName)) {
                Write-Host "已取消操作。" -ForegroundColor Red
                exit 1
            }
            Write-Host "正在停止现有服务..."
            & $nssmPath stop $ServiceName confirm
            Write-Host "正在删除现有服务..."
            & $nssmPath remove $ServiceName confirm
            Write-Host "已发送指令，等待生效..." -NoNewline

            $waitingSecond = 0
            while ($null -ne (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
                Write-Host "." -NoNewline
                Start-Sleep -Seconds 1
                $waitingSecond++
                if ($waitingSecond -ge 10) {
                    Write-Host "服务删除超时，请确认服务未被占用，比如没有窗口仍在浏览它。" -ForegroundColor Red
                    exit 1
                }
            }
            Write-Host "服务已删除。" -ForegroundColor Green
        }
    } catch {
        Write-Error "检查服务状态时出错：$_"
        exit 1
    }
}
