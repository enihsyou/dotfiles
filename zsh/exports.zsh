# set temp folder into ram disk
[ -e /Volumes/RAM ] && export TMPDIR=/Volumes/RAM/Cache/Shell

# quick fix for IntelliJ IDEA Terminal, when executing `zsh` inside zsh,
# zsh-newuser-install will always run because this variable is empty.
export ZDOTDIR=~
