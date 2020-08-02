# set temp folder into ram disk
if [[ -e /Volumes/RAM ]]; then
    mkdir -p /Volumes/RAM/Cache/Shell
    export TMPDIR=/Volumes/RAM/Cache/Shell
fi
# quick fix for IntelliJ IDEA Terminal, when executing `zsh` inside zsh,
# zsh-newuser-install will always run because this variable is empty.
export ZDOTDIR=~

# export my ssh public key as environment variable
export SSH_KEY_PATH="$HOME/.ssh/enihsyou"

# explict disable compaudit check in order to boot startup time.
export ZSH_DISABLE_COMPFIX=true
