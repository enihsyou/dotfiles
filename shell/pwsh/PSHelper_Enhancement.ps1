# 本文件放置对日常命令行操作的增强函数。

# 使用指定的 bot 身份创建 Git 提交
function git-bot-commit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$UserName,

        [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
        [string[]]$CommitArguments
    )

    $userNameAliases = @{
        'sol-6'    = 'GPT-6 Sol - Codex'
        'sol-5.6'  = 'GPT-5.6 Sol - Codex'
        'terra'    = 'GPT-5.6 Terra - Codex'
        'luna-6'   = 'GPT-6 Luna - Codex'
        'luna-5.6' = 'GPT-5.6 Luna - Codex'
        'astra'    = 'GPT-6 Astra - Codex'
        'm3'       = 'MiniMax-M3 - Claude Code'
    }
    $shortcuts = @{
        'sol'  = 'sol-6'
        'luna' = 'luna-6'
    }
    foreach ($shortcut in $shortcuts.GetEnumerator()) {
        $userNameAliases[$shortcut.Key] = $userNameAliases[$shortcut.Value]
    }

    if ($userNameAliases.ContainsKey($UserName)) {
        $UserName = $userNameAliases[$UserName]
    }

    $gitArguments = @(
        'commit'
        '--no-gpg-sign'
        '--trailer=Co-Authored-By: 九条涼果 <enihsyou@gmail.com>'
        "--author=$UserName <292837902+arapacati[bot]@users.noreply.github.com>"
    ) + $CommitArguments

    & git @gitArguments
}

# findstr 不好用，既然要换就换好的
# https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#how-do-i-create-an-alias-for-ripgrep-on-windows
# 若遭遇输出编码，需调用 utf8 函数切换编码
function grep {
    $count = @($input).Count
    $input.Reset()

    if ($count) {
        $input | rg.exe --hidden $args
    }
    else {
        rg.exe --hidden $args
    }
}

# pnpm alias
Function nx { & pnpm dlx @args }

# bun alias
# winget install bun 不会把 bunx.exe 添加到 PATH 中
Function bunx { bun x @args }

# 从镜像注册表镜像站拉取镜像
function docker-pull-mirror {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Image
    )

    if ([string]::IsNullOrWhiteSpace($Image)) {
        throw 'Usage: docker-pull-mirror <image>'
    }

    $mirrors = @(ConvertTo-DockerMirrorImage -Image $Image)
    $interrupted = $false

    if ($mirrors.Count -gt 0) {
        foreach ($mirror in $mirrors) {
            try {
                Write-Host "==> Trying mirror: $mirror"
                & docker pull $mirror
            }
            catch [System.Management.Automation.PipelineStoppedException] {
                # Ctrl+C 中断当前代理的拉取，尝试下一个而不是停下
                $interrupted = $true
                Write-Host "==> Interrupted, skipping to next mirror"
                continue
            }
            if ($LASTEXITCODE -eq 0) {
                # 代理拉取成功后，直接给镜像打 tag，建立与源镜像名的联系，
                # 避免再从源仓库 pull 一次（典型情况：源仓库不可达）。
                Write-Host "==> Tagging $mirror as $Image"
                & docker tag $mirror $Image
                if ($LASTEXITCODE -ne 0) {
                    throw "Pulled $mirror, but failed to tag it as $Image."
                }
                return
            }
        }
    }

    if ($interrupted) {
        # 用户跳过了所有代理，不再回源仓库拉取
        Write-Host "==> All mirrors skipped; aborting."
        return
    }

    # 所有代理都不可达时，回源源仓库拉取
    Write-Host "==> All mirrors unreachable; pulling from source: $Image"
    & docker pull $Image
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to pull $Image from any mirror and from source."
    }
}

# dig as DNS client on Windows
function dig { doggo --strategy=random --time @args }

# rg with vscode hyperlink format
function rgv { rg --hyperlink-format=vscode @args }

# rsync from MSYS2 will need '-e /usr/bin/ssh' to specify ssh client within MSYS2
# to function correctly.
function rsync { rsync.exe -e /usr/bin/ssh @args }

# ls 继续保持使用 Get-ChildItem
function ll { eza --long --icons @args }

# 切换电源模式
function powermode {
    param([string]$Mode)

    $powerModes = @{
        '1' = @{ Guid = 'a1841308-3541-4fab-bc81-f71556f20b4a'; GpuTask = 'GPU-PowerMode-Eco' } # 节能
        '2' = @{ Guid = '381b4222-f694-41f0-9685-ff5bb260df2e'; GpuTask = 'GPU-PowerMode-Normal' } # 平衡
        '3' = @{ Guid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'; GpuTask = 'GPU-PowerMode-Performance' } # 高性能
    }

    if ([string]::IsNullOrWhiteSpace($Mode) -or -not $powerModes.ContainsKey($Mode)) {
        Write-Host 'Usage: powermode <1|2|3>'
        Write-Host '  1 = CPU 节能降频 + GPU 50% 功耗'
        Write-Host '  2 = CPU 基准频率 + GPU 70% 功耗'
        Write-Host '  3 = CPU 自动睿频 + GPU 100% 功耗'
        powercfg /l
        return
    }

    $selectedMode = $powerModes[$Mode]
    powercfg /s $selectedMode.Guid
    schtasks.exe /run /tn $selectedMode.GpuTask | Out-Null
    if ($LASTEXITCODE -ne 0) {
        schtasks.exe /query /tn $selectedMode.GpuTask *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Host '找不到 GPU PowerMode 计划任务，请运行 register-gpu-powermode-tasks.ps1 注册。'
        }
    }
    powercfg /l
}

# 当 Tmux 意外退出而没有恢复终端状态时，可以硬重置中断状态
function Reset-Terminal {
    [Console]::Write("`ec")
}

function ask {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Question
    )

    $q = $Question -join ' '

    codex exec `
        --skip-git-repo-check `
        --sandbox read-only `
        --search `
        --disable hooks `
        --disable shell_tool `
        --disable unified_exec `
        -m 'gpt-6-luna' `
        -c 'model_reasoning_effort="high"' `
        $q
}

# https://yazi-rs.github.io/docs/quick-start
function y {
    $yazi = Get-Command yazi -CommandType Application -TotalCount 1 -ErrorAction SilentlyContinue
    if ($null -eq $yazi) {
        throw '找不到 yazi，请先安装并确保它在 PATH 中。'
    }

    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & $yazi.Path $args --cwd-file="$tmp"
        $cwd = Get-Content -LiteralPath $tmp -Encoding UTF8 | Select-Object -First 1
        if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
            Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
        }
    }
    finally {
        Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
    }
}
