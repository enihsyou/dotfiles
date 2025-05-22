will_install() {
    echo -e "[\e[1;34mInstall $1\e[0m]"
}

if [[ ! -d "${HOME}/.vim_runtime/" ]]; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
fi

ln -s ~/.dotfiles/vim/my_config.vim ~/.vim_runtime/my_configs.vim
