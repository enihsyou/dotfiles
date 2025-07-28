#!/usr/bin/env bash

# If DOTFILES is not set, Use git repository for it
if [ -z "$DOTFILES" ]; then
    DOTFILES=$(git rev-parse --show-toplevel 2>/dev/null)
fi
if [ -z "$DOTFILES" ]; then
    echo "DOTFILES environment variable is not set and cannot determine the git repository root."
    exit 1
fi

# Disable session save/restore mechanism
if ! [ -f ~/.bash_sessions_disable ]; then
    touch ~/.bash_sessions_disable
fi
if ! grep --quiet --no-messages "SHELL_SESSIONS_DISABLE=1" ~/.zshenv; then
    # please preserve tab when editing
    cat <<-EOF >>~/.zshenv
# Disable session save/restore mechanism
# https://stackoverflow.com/questions/32418438/how-can-i-disable-bash-sessions-in-os-x-el-capitan
SHELL_SESSIONS_DISABLE=1
EOF
fi

# Install antidote
if ! command -v antidote &>/dev/null; then
    brew install antidote
    zsh << EOF
source $(brew --prefix antidote)/share/antidote/antidote.zsh
antidote bundle <$DOTFILES/shell/zsh/zsh_plugins.txt >$HOME/.zsh_plugins.zsh
antidote update
EOF
fi

#  Install awesome vimrcs
if ! [ -f ~/.vim_runtime/vimrcs/basic.vim ]; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
fi
