#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Path shortcut to this dotfiles path is $DOTFILES
export DOTFILES="$HOME/.dotfiles"

# Path to the bash it configuration
export BASH_IT="$HOME/.bash_it"

# Path to custom content instead of $BASH_IT
export BASH_IT_CUSTOM="$DOTFILES/cli-app/bash-it"

# Lock and Load a custom theme file.
# Leave empty to disable theming.
# location "$BASH_IT"/themes/
export BASH_IT_THEME="$BASH_IT_CUSTOM/enihsyou.theme.bash"

# Some themes can show whether `sudo` has a current token or not.
# Set `$THEME_CHECK_SUDO` to `true` to check every prompt:
#THEME_CHECK_SUDO='true'

# Don't check mail when opening terminal.
unset MAILCHECK

# Set this to the location of your work or project folders
BASH_IT_PROJECT_PATHS="$HOME/GitHub"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=false
# per default gitstatus uses 2 times as many threads as CPU cores, you can change this here if you must
#export GITSTATUS_NUM_THREADS=8

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
#export SHORT_HOSTNAME=$(hostname -s)

# Set Xterm/screen/Tmux title with only a short username.
# Uncomment this (or set SHORT_USER to something else),
# Will otherwise fall back on $USER.
#export SHORT_USER=${USER:0:8}

# If your theme use command duration, uncomment this to
# enable display of last command duration.
export BASH_IT_COMMAND_DURATION=true
# You can choose the minimum time in seconds before
# command duration is displayed.
export COMMAND_DURATION_MIN_SECONDS=0

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#export SHORT_TERM_LINE=true

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Load Bash It
source "$BASH_IT"/bash_it.sh

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  # shellcheck disable=SC2015
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# 当前在 /etc/wsl.conf 设置了 appendWindowsPath=false，这个函数用来在必要时候
# 手动添加 Windows 的 PATH 到 WSL2 的 PATH 里
function win() {
  # 列表手动同步吧
  local win_path=(
    "/mnt/c/Program Files/OpenSSH/"
    "/mnt/c/WINDOWS/system32"
    "/mnt/c/WINDOWS"
    "/mnt/c/Program Files/dotnet/"
    "/mnt/c/Program Files/Docker/Docker/resources/bin"
    "/mnt/c/Program Files/Git/cmd"
    "/mnt/c/Program Files/PowerShell/7"
    "/mnt/c/Program Files/CMake/bin"
    "/mnt/c/Users/enihsyou/.local/bin"
    "/mnt/c/Users/enihsyou/.cargo/bin"
    "/mnt/c/Users/enihsyou/.bun/bin"
    "/mnt/c/Users/enihsyou/AppData/Local/pnpm"
    "/mnt/c/Users/enihsyou/AppData/Local/npm"
    "/mnt/c/Users/enihsyou/AppData/Local/go/bin"
    "/mnt/c/Users/enihsyou/AppData/Local/Ruby/ruby34/bin"
    "/mnt/c/Users/enihsyou/.vfox/sdks/nodejs/bin"
    "/mnt/c/Users/enihsyou/.vfox/sdks/python"
    "/mnt/c/Users/enihsyou/.vfox/sdks/golang/bin"
    "/mnt/c/Users/enihsyou/AppData/Local/Microsoft/WinGet/Links"
    "/mnt/c/Users/enihsyou/AppData/Local/JetBrains/Toolbox/scripts"
    "/mnt/c/Users/enihsyou/AppData/Local/Microsoft/WindowsApps"
    "/mnt/c/Users/enihsyou/AppData/Local/Programs/Microsoft VS Code/bin"
    "/mnt/c/Users/enihsyou/.dotnet/tools"
  )

  for p in "${win_path[@]}"; do
    if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
      PATH="$PATH:$p"
    fi
  done
  export PATH
}

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# version-fox
export PATH="$PATH:$HOME/.vfox/sdks/nodejs/bin"
export PATH="$PATH:$HOME/.vfox/sdks/golang/bin"
export VFOX_GOLANG_MIRROR="https://mirrors.aliyun.com/golang/"
export VFOX_PYTHON_MIRROR="https://mirrors.aliyun.com/python-release/"
export VFOX_NODEJS_MIRROR="https://mirrors.aliyun.com/nodejs-release/"

# agent setup, moved from dotbot to here to avoid sudo issues
# source "$DOTFILES/system/WSL2/profile.d/wsl-ssh-agent.sh"
# source "$DOTFILES/system/WSL2/profile.d/wsl-gpg-agent.sh"
#
# profile script is deprecated in favor of systemd user service
# see system/WSL2/systemd/user/wsl-ssh-agent.service
# the only nessesary step now is to set environment variable
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-${XDG_RUNTIME_DIR%/}/ssh/ssh-agent.sock}"

# hide kernel processes in `ps` output
export LIBPROC_HIDE_KERNEL=1

function x() {
  echo "🚨 x not loaded! Loading now..." >&2
  unset -f x
  [ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
  x "$@"                                                    # invoke the real function now
}

function ble() {
  # enable auto completion by execute `ble` on current shell.
  # make sure to install before using:
  # curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf -
  # bash ble-nightly/ble.sh --install ~/.local/share
  [[ $- == *i* ]] && source -- "$HOME/.local/share/blesh/ble.sh" --rcfile "$DOTFILES/cli-app/blesh/blerc"
}

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
