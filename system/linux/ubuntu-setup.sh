#!/usr/bin/env bash
# Setup Ubuntu 24.04

# Enable colorful PS1 on Ubuntu
sed -i 's/xterm-color) color_prompt/xterm-color|*-256color) color_prompt/g' .bashrc

# Install latest version of bat
wget https://gh-proxy.com/https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb
dpkg -i bat_0.25.0_amd64.deb
ln -s /usr/bin/batcat /usr/bin/bat
# Download my configuration file
wget https://gh-proxy.com/https://github.com/enihsyou/dotfiles/blob/Windows/cli-app/bat/config -O "$(bat --config-file)"
