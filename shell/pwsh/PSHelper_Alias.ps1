Function which_GetCommand_SourceOnly {
    # similar to `which` in Linux
    param([string]$Name)
    if ($null -eq $Name -or $Name -eq '') {
        return 'Usage: which <command>'
    }
    $command = Get-Command -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source.Replace('\','/')
    }
    return ''
}

# msys2 alias
Function msys2_launcher {
    # 调用函数传递的或者从上层通过 @args 传来的多个参数作为 "$args" 整体调用
    param([string]$Shell)
    if ($args.Count -eq 0) {
        & "C:\msys64\msys2_shell.cmd" -defterm -here -no-start -$Shell
    } else {
        & "C:\msys64\msys2_shell.cmd" -defterm -here -no-start -$Shell -c "$args"
    }
}
Function msys2 { & msys2_launcher -Shell msys2 @args }
Function ucrt64 { & msys2_launcher -Shell ucrt64 @args }
Function mingw64 { & msys2_launcher -Shell mingw64 @args }
Function clang64 { & msys2_launcher -Shell clang64 @args }
Set-Alias -Name msys -Value ucrt64

# some linux like alias
# which 和 touch 在 x-cmd 中有更好的实现，如果 source 了它会覆盖掉这里
Set-Alias -Name which -Value which_GetCommand_SourceOnly
Set-Alias -Name touch -Value New-Item
Set-Alias -Name open -Value explorer

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
        'sol'   = 'GPT-5.6 Sol - Codex'
        'terra' = 'GPT-5.6 Terra - Codex'
        'luna'  = 'GPT-5.6 Luna - Codex'
        'astra' = 'GPT-6 Astra - Codex'
        'm3'    = 'MiniMax-M3 - Claude Code'
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
Set-Alias -Name np -Value pnpm
Function nx { & pnpm dlx @args }

# bun alias
# winget install bun 不会把 bunx.exe 添加到 PATH 中
Function bunx { bun x @args }

# Since I always forget I am on Windows not macOS.
Set-Alias -Name brew -Value winget -Description "Alias to winget, for macOS users"

# HTTPie 启动耗时太慢，换成 Rust 版
Set-Alias -Name http -Value xh -Description "a Rust version of HTTPie"

# 从镜像注册表镜像站拉取镜像

function ConvertTo-DockerMirrorImage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Image
    )

    $registry = 'docker.io'
    $imagePath = $Image
    if ($Image -match '^(?<firstComponent>[^/]+)/(?<path>.+)$') {
        $firstComponent = $Matches.firstComponent
        if ($firstComponent -eq 'localhost' -or $firstComponent.Contains('.') -or $firstComponent.Contains(':')) {
            $registry = $firstComponent
            $imagePath = $Matches.path
        }
    }

    # 每个镜像仓库提供多个候选代理。前面的优先级更高。
    $proxyTemplates = switch ($registry.ToLowerInvariant()) {
        'ghcr.io' {
            @('ghcr.nju.edu.cn', 'wget.la/ghcr.io')
            break
        }
        'quay.io' {
            @('quay.nju.edu.cn', 'wget.la/quay.io')
            break
        }
        'gcr.io' {
            @('gcr.nju.edu.cn')
            break
        }
        'registry.k8s.io' {
            @('k8s.nju.edu.cn', 'wget.la/registry.k8s.io')
            break
        }
        'nvcr.io' {
            @('nvcr.nju.edu.cn', 'ngc.nju.edu.cn')
            break
        }
        'registry.gitlab.com' {
            @('glcr.nju.edu.cn')
            break
        }
        'docker.io' {
            if ($imagePath.StartsWith('library/')) {
                $imagePath = $imagePath.Substring('library/'.Length)
            }
            @('wget.la', 'gh-proxy.com', 'm.daocloud.io/docker.io', 'docker.m.daocloud.io')
            break
        }
        default {
            @()
        }
    }

    $mirrors = foreach ($tpl in $proxyTemplates) { "$tpl/$imagePath" }

    return @($mirrors)
}

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
            } catch [System.Management.Automation.PipelineStoppedException] {
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

# 删除默认指向 Where-Object 的别名，转而调用 where.exe
Remove-Alias -Name where -Force -ErrorAction Ignore

# dig as DNS client on Windows
function dig { doggo --strategy=random --time @args }

# rg with vscode hyperlink format
function rgv { rg --hyperlink-format=vscode @args }

# rsync from MSYS2 will need '-e /usr/bin/ssh' to specify ssh client within MSYS2
# to function correctly.
function rsync { rsync.exe -e /usr/bin/ssh @args }

# ls 继续保持使用 Get-ChildItem
function ll { eza --long --icons @args }
Set-Alias -Name lss -Value eza -Description "a modern replacement for ls"

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
