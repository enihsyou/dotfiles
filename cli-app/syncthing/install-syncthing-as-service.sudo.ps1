<#
.SYNOPSIS
    Installs Syncthing as a Windows service
.DESCRIPTION
    Uses NSSM (Non-Sucking Service Manager) to set up Syncthing as a Windows
    service. Requires both Syncthing and NSSM to already be installed. nssm.exe
    must be available via the PATH environment variable.
.PARAMETER ServiceName
    Defaults to "Syncthing"
.NOTES
    Reference: https://gist.github.com/pcrockett-pathway/76f5cbdd578c17ef2a12a804959f2060
#>

#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter()]
    [string]$ServiceName = "Syncthing"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

if (!(Get-Command "nssm" -ErrorAction SilentlyContinue)) {
    throw "nssm.exe not found. Make sure it is included in the PATH environment variable."
}

# get full path to syncthing.exe
$syncthingExe = Get-Command syncthing.exe -ErrorAction SilentlyContinue
if (!$syncthingExe) {
    throw "syncthing.exe not found. Make sure it is included in the PATH environment variable."
}
$syncthingExe = $syncthingExe.Source

if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing service $ServiceName ..." -ForegroundColor Yellow
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Remove-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    $waitingSecond = 0
    while (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 1
        $waitingSecond++
        if ($waitingSecond -ge 10) {
            throw "Removing service $ServiceName timed out. Please check if the service is still in use, for example, if there are no windows still browsing it."
        }
    }
}

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$serviceCreds = Get-Credential -UserName $currentUser -Message "The Syncthing service should run under the current user to reduce security risks."

# most settings can be obtained by: nssm dump <serviceName>
$nssmSettings = @{
    AppParameters   = "--no-restart --no-browser --no-console"
    DisplayName     = "Syncthing Service [managed by nssm]"
    Description     = "Syncthing is a continuous file synchronization program."
    Start           = "SERVICE_DELAYED_AUTO_START"
    DependOnService = "Tcpip"
    AppNoConsole    = "1"
    AppExit         = @{
        # https://docs.syncthing.net/users/autostart.html#autostart-windows-taskschd
        Default = "Exit"
        1       = "Restart"
        2       = "Restart"
        3       = "Restart"
        4       = "Restart"
    }
    ObjectName      = @{
        $serviceCreds.UserName = $serviceCreds.GetNetworkCredential().Password
    }
}

function Invoke-Nssm {
    nssm $args
    if ($LASTEXITCODE -ne 0) {
        throw "nssm exited with code $LASTEXITCODE"
    }
}

Invoke-Nssm install $ServiceName $syncthingExe
foreach ($setting in $nssmSettings.GetEnumerator()) {
    if ($setting.Value -is [hashtable]) {
        foreach ($subSetting in $setting.Value.GetEnumerator()) {
            Invoke-Nssm set $ServiceName $setting.Key $subSetting.Key $subSetting.Value
        }
    } else {
        Invoke-Nssm set $ServiceName $setting.Key $setting.Value
    }
}

Start-Service -Name $ServiceName
