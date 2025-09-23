#!/usr/bin/env sh
# Expose Win32-OpenSSH Agent to WSL/MSYS2 environments
# source: https://github.com/microsoft/WSL/issues/11207#issuecomment-2921237689
#
# This script targets the native Windows SSH implementation,
# NOT the ssh-agent included with Git for Windows, MSYS2, or WSL2.
# Ensure the correct implementation is matched.
# - Win32-OpenSSH https://github.com/PowerShell/Win32-OpenSSH
# - nieperelay    https://github.com/jstarks/npiperelayWindows
#
# Note that use of systemd unit files is recommended in WSL2 environments.

runtime_dir="${XDG_RUNTIME_DIR:-/tmp/run/$UID/}"
export SSH_AUTH_SOCK="${runtime_dir%/}/ssh/ssh-agent.sock"
unset runtime_dir

# Exit if socket already exists and is a valid socket
if command -v ss; then
  if ss -lxn | grep -q "$SSH_AUTH_SOCK"; then
    return
  fi
else
  # Fallback to test file existence if other method is not available
  if [ -S "$SSH_AUTH_SOCK" ]; then
    return
  fi
fi

# Remove the stale socket, if it exists
rm -f "$SSH_AUTH_SOCK"

# Launch socat/npiperelay as a background process
(setsid socat \
  UNIX-LISTEN:"$SSH_AUTH_SOCK",umask=007,fork \
  EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork \
  &) >/dev/null 2>&1
