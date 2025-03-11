# Must be run from PowerShell run as Administrator

# Install from Windows Package Manager
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget import --import-file winget-export.json --no-upgrade --ignore-unavailable --accept-package-agreements
} else {
    Write-Warning "Skipping winget import because winget is unavailable. Ensure you are running a compatible version of Windows and have winget installed."
}

# Configure Optional Windows Features
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform               # Enable Windows VM Platform          
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux    # Enable WSL
