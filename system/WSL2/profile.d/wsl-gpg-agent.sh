#!/usr/bin/env sh
# Expose Git for Windows (Cygwin) GPG Agent to WSL environments
#
# This script targets the cygwin/msys2 GPG agent implementation,
# which use a cygwin emulated UNIX domain socket.
# NOT the Agent included with Gpg4win, or WSL2.
# Ensure the correct implementation is matched.
# - gpg-agent.exe C:\Program Files\Git\usr\bin\gpg-agent.exe typlically
# - nieperelay    https://github.com/albertony/npiperelay the forked version
#
# Note that use of systemd unit files is recommended in WSL2 environments.

socat_gpg_agent_socket() {
  local socket_path="$1"
  local socket_name="${socket_path##*/}"
  # Exit if socket already exists and is a valid socket
  if ss -lxn | grep -q "$socket_path"; then
    return
  fi

  # Remove the stale socket, if it exists
  rm -f "$socket_path"

  # Launch socat/npiperelay as a background process
  (setsid socat \
    UNIX-LISTEN:"$socket_path",umask=007,fork \
    EXEC:"npiperelay.exe -ei -s -c C\:/Users/$USER/.gnupg/$socket_name",nofork \
    &) >/dev/null 2>&1
}

# e.g. /run/user/1000/gnupg/S.gpg-agent
socat_gpg_agent_socket "$(gpgconf --list-dirs agent-socket)"
# e.g. /run/user/1000/gnupg/S.gpg-agent.ssh
socat_gpg_agent_socket "$(gpgconf --list-dirs agent-ssh-socket)"
