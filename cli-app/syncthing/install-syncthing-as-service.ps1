# 使用 nssm 安装 syncthing 服务
# https://docs.syncthing.net/users/autostart.html#autostart-windows-taskschd

# 环境变量在 sudo 时也要保证注入
Import-Module -Name "$env:DOTFILES\shell\pwsh\Modules\NssmHelper.psm1" -Force -DisableNameChecking

# 权限自提升
$SudoScript = Join-Path $PSScriptRoot 'install-syncthing-as-service.sudo.ps1'
Require-Sudo $SudoScript
