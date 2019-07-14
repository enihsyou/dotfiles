# Install powerlevel9k theme
git submodule init
git submodule update

will_install() {
    echo -e "[\e[1;34mInstall $1\e[0m]"
}

linuxSpecific() {
    will_install jq
    sudo apt -y install jq

    will_install unar
    sudo apt -y install unar

    will_install exa
    wget https://github.com/ogham/exa/releases/download/v0.8.0/exa-linux-x86_64-0.8.0.zip
    unar -D -f exa-linux-x86_64-0.8.0.zip && rm exa-linux-x86_64-0.8.0.zip
    sudo mv exa-linux-x86_64 /usr/bin/exa
}

darwinSpecific() {
    return
}

case $(uname) in
    Linux*)  linuxSpecific;;
    Darwin*) darwinSpecific;;
    *) echo "Unsupported OS type" >&2
esac
