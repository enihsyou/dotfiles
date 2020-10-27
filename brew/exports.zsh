# Specify brew defaults in this environment variable
# https://docs.brew.sh/Manpage#environment
export HOMEBREW_BAT=1
export HOMEBREW_CASK_OPTS="--fontdir=~/Library/Fonts"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=45
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
export HOMEBREW_BREW_GIT_REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
export HOMEBREW_CORE_GIT_REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git

# export brew linked binary
export PATH="/usr/local/sbin:$PATH:~/.local/bin"

# export brew installed python@3.8
export PATH="/usr/local/opt/python@3.8/bin:$PATH"

# export brew installed nodejs home
export NODEJS_HOME="/usr/local/opt/node"
# export brew installed yarn home
export YARN_HOME="/usr/local/opt/yarn"
