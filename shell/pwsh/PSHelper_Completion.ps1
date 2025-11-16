# 本文件用于设置 PowerShell 的命令行补全

# GitHub CLI https://cli.github.com/manual/gh_completion
Invoke-Expression (gh completion -s powershell | Out-String)

# pnpm
Invoke-Expression (pnpm completion pwsh | Out-String)

# https://taskfile.dev/installation#setup-completions
Invoke-Expression (& task --completion powershell | Out-String)
