#!/usr/bin/env sh
# non-interactive profile for MSYS2 as well as Git Bash for Windows
# filepath: ~/.profile

# If we're in MSYS2 (not Git-Bash)
if [ -n "$MSYSTEM_PREFIX" ]; then
  # add openssh to PATH if not already present
  # 和 rsync 有些冲突，先注释掉
  # if [ -x "$PROGRAMFILES/OpenSSH/ssh-add.exe" ]; then
  #   unix_path=$(cygpath -u "$PROGRAMFILES/OpenSSH")
  #   if [[ ":$PATH:" != *":$unix_path:"* ]]; then
  #     export PATH="$PATH:$unix_path"
  #   fi
  # fi
  # transfer some Windows PATH to MSYS2
  export PATH="$PATH:$HOME/.local/bin"
  export PATH="$PATH:$HOME/.cargo/bin"
  export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links"
fi

source $HOME/.dotfiles/system/MSYS2/profile.d/msys2-ssh-agent.sh
