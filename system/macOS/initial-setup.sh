#!/usr/bin/env bash
return
# Disable session save/restore mechanism
if ! [ -f ~/.bash_sessions_disable ]; then
    touch ~/.bash_sessions_disable
fi
if ! grep --quiet --no-messages "SHELL_SESSIONS_DISABLE=1" ~/.zshenv; then
    cat <<-EOF >>~/.zshenv # please preserve tab when editing
# Disable session save/restore mechanism
# https://stackoverflow.com/questions/32418438/how-can-i-disable-bash-sessions-in-os-x-el-capitan
SHELL_SESSIONS_DISABLE=1
EOF
fi

# Install antidote
if ! command -v antidote &>/dev/null; then
    brew install antidote
    source "$(brew --prefix antidote)/share/antidote/antidote.zsh"
    antidote bundle < "${DOTFILES:-$HOME/.dotfiles}/zsh/zsh_plugins.txt" > "$HOME/.zsh_plugins.zsh"
    source ~/.zshrc
fi

#  Install awesome vimrcs
if ! [ -f ~/.vim_runtime/vimrcs/basic.vim ]; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
fi
