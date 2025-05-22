# Install from Windows Package Manager
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget import --import-file winget-export.json --no-upgrade --ignore-unavailable --accept-package-agreements
} else {
    Write-Warning "Skipping winget import because winget is unavailable. Ensure you are running a compatible version of Windows and have winget installed."
}
