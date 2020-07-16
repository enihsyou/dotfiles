# Specify your defaults in this environment variable
export HOMEBREW_CASK_OPTS="--fontdir=~/Library/Fonts"
export HOMEBREW_NO_AUTO_UPDATE=1
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

# export brew linked binary
export PATH="/usr/local/sbin:$PATH:~/.local/bin"

# export brew installed python@3.8
export PATH="/usr/local/opt/python@3.8/bin:$PATH"

# export brew installed nodejs home
export NODEJS_HOME="/usr/local/opt/node"
# export brew installed yarn home
export YARN_HOME="/usr/local/opt/yarn"

# export rbenv
eval "$(rbenv init -)"
