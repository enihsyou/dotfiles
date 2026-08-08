# 创建供 powermode 使用的 NVIDIA GPU 功耗计划任务。
# 请以管理员身份运行一次；任务以 SYSTEM 的最高权限执行，当前用户仅获查询和运行权限。

[CmdletBinding()]
param(
    [ValidateRange(0, 31)]
    [int]$GpuIndex = 0
)

$ErrorActionPreference = 'Stop'

function Write-RegistrationProgress {
    param([string]$Message)

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message"
}

function Assert-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw '请在“以管理员身份运行”的 PowerShell 中执行此脚本。'
    }
}

function Get-GpuPowerLimits {
    param([string]$NvidiaSmi, [int]$Index)

    $query = & $NvidiaSmi "--id=$Index" --query-gpu=power.default_limit,power.min_limit,power.max_limit --format=csv,noheader,nounits
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($query)) {
        throw "无法读取 GPU $Index 的功耗限制。"
    }

    $values = $query.Trim().Split(',') | ForEach-Object {
        [double]::Parse($_.Trim(), [Globalization.CultureInfo]::InvariantCulture)
    }
    if ($values.Count -ne 3) {
        throw "无法解析 GPU $Index 的功耗限制：$query"
    }

    return @{ Default = $values[0]; Minimum = $values[1]; Maximum = $values[2] }
}

function Register-GpuPowerTask {
    param(
        [string]$TaskName,
        [string]$NvidiaSmi,
        [int]$Index,
        [double]$PowerLimit
    )

    # 任务本身以 SYSTEM + Highest 权限运行。
    $action = New-ScheduledTaskAction `
        -Execute $NvidiaSmi `
        -Argument "--id=$Index --power-limit=$PowerLimit"
    $principal = New-ScheduledTaskPrincipal `
        -UserId 'SYSTEM' `
        -LogonType ServiceAccount `
        -RunLevel Highest

    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Principal $principal `
        -Force | Out-Null

    # 当前用户仅可读取和启动任务，不能修改或删除任务。
    $userSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $ace = "(A;;FRFX;;;$userSid)"

    $scheduler = New-Object -ComObject 'Schedule.Service'
    $scheduler.Connect()
    $folder = $scheduler.GetFolder('\')
    $task = $folder.GetTask($TaskName)

    # 4 = DACL_SECURITY_INFORMATION
    $sddl = $task.GetSecurityDescriptor(4)
    if ($sddl -notlike "*$ace*") {
        $task.SetSecurityDescriptor($sddl + $ace, 0)
    }
}

Assert-Administrator
Write-RegistrationProgress '开始注册 GPU PowerMode 计划任务。'

if ($PSVersionTable.PSEdition -eq 'Core') {
    Write-RegistrationProgress '加载 Windows 计划任务模块。'
    Import-Module ScheduledTasks -UseWindowsPowerShell
}
else {
    Write-RegistrationProgress '加载 Windows 计划任务模块。'
    Import-Module ScheduledTasks
}

Write-RegistrationProgress '读取 GPU 的 VBIOS 功耗范围。'
$nvidiaSmi = (Get-Command nvidia-smi.exe -ErrorAction Stop).Source
$limits = Get-GpuPowerLimits -NvidiaSmi $nvidiaSmi -Index $GpuIndex

$taskNames = @(
    'GPU-Eco',
    'GPU-Normal',
    'GPU-PowerMode-Eco',
    'GPU-PowerMode-Normal',
    'GPU-PowerMode-Performance'
)
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 删除旧计划任务" -NoNewline
foreach ($taskName in $taskNames) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host '.' -NoNewline
}
Write-Host

$performanceLimit = [Math]::Min($limits.Maximum, [Math]::Round($limits.Default * 1.05, 0))

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 创建新计划任务" -NoNewline
Register-GpuPowerTask -TaskName 'GPU-PowerMode-Eco' -NvidiaSmi $nvidiaSmi -Index $GpuIndex -PowerLimit $limits.Minimum
Write-Host '.' -NoNewline
Register-GpuPowerTask -TaskName 'GPU-PowerMode-Normal' -NvidiaSmi $nvidiaSmi -Index $GpuIndex -PowerLimit $limits.Default
Write-Host '.' -NoNewline
Register-GpuPowerTask -TaskName 'GPU-PowerMode-Performance' -NvidiaSmi $nvidiaSmi -Index $GpuIndex -PowerLimit $performanceLimit
Write-Host '.'

Write-RegistrationProgress "已创建 GPU 计划任务：节能 $($limits.Minimum)W，默认 $($limits.Default)W，高性能 $performanceLimit W。"
