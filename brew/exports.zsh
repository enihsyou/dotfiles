# Specify brew defaults in this environment variable
# https://docs.brew.sh/Manpage#environment

export HOMEBREW_BAT=1
#export HOMEBREW_CURLRC=1
export HOMEBREW_CURL_RETRIES=1
#export HOMEBREW_VERBOSE=1
#export HOMEBREW_VERBOSE_USING_DOTS=1
# unsetting with brew 4.0 updates
#export HOMEBREW_NO_AUTO_UPDATE=1
#export HOMEBREW_NO_INSTALL_CLEANUP=1
#export HOMEBREW_CLEANUP_MAX_AGE_DAYS=21
#export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=10
export HOMEBREW_DISPLAY_INSTALL_TIMES=1
export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1

# disable tuna mirror, credit: https://www.tinkol.com/372
#if [[ "$(uname -s)" == "Linux" ]]; then BREW_TYPE="linuxbrew"; else BREW_TYPE="homebrew"; fi
#export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
#export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/${BREW_TYPE}-core.git"
#export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/${BREW_TYPE}-bottles/bottles"
#unset BREW_TYPE

# set temp folder into ram disk
if [[ -e /Volumes/RAM ]]; then
    mkdir -p /Volumes/RAM/Cache
    export HOMEBREW_TEMP="/Volumes/RAM/Cache"
fi
