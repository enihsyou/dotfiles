#!/usr/bin/env sh
# Expose Win32-OpenSSH Agent to MSYS2 environments
# source see wsl-ssh-agent.sh in this repo.
#
# This script need npiperelay.exe compiled with MSYS2 go runtime in order to
# make cygwin unix domain socket works. And it only compatible with OpenSSH
# client installed INSIDE MSYS2 (not to be confused with Win32-OpenSSH).
# - nieperelay    https://github.com/jstarks/npiperelayWindows

export SSH_AUTH_SOCK="/tmp/run/ssh-agent.sock"

# Exit if socket already exists
if [ -S "$SSH_AUTH_SOCK" ]; then
  return
fi

mkdir -p /tmp/run

# Launch socat/npiperelay as a background process
(setsid socat \
  UNIX-LISTEN:"$SSH_AUTH_SOCK",umask=007,fork \
  EXEC:"npiperelay-msys2.exe -ei -s //./pipe/openssh-ssh-agent",nofork \
  &) >/dev/null 2>&1
