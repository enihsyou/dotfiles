# 本文件放置交互命令共用的辅助函数，不直接提供主要用户入口。

Function which_GetCommand_SourceOnly {
    # similar to `which` in Linux
    param([string]$Name)
    if ($null -eq $Name -or $Name -eq '') {
        return 'Usage: which <command>'
    }
    $command = Get-Command -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source.Replace('\', '/')
    }
    return ''
}

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
