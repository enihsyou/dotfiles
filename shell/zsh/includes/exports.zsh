# tweak the zsh shell behavior

# Enable 256bit color
#export TERM="xterm-256color"
export CLICOLOR=true

# set locale to chinese
#export LANG="zh_CN.UTF-8"

# set temp folder into ram disk
# if [[ -e /Volumes/RAM ]]; then
#     mkdir -p /Volumes/RAM/Cache/Shell
#     export TMPDIR=/Volumes/RAM/Cache/Shell
# fi
# quick fix for IntelliJ IDEA Terminal, when executing `zsh` inside zsh,
# zsh-newuser-install will always run because this variable is empty.
export ZDOTDIR=~

# export my ssh public key as environment variable
export SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# explict disable compaudit check in order to boot startup time.
# this have moved to .zshrc
#export ZSH_DISABLE_COMPFIX=true
