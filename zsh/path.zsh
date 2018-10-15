# sup yarn
# https://yarnpkg.com
exist yarnpkg &&
export PATH="$PATH:`yarnpkg global bin`"

exist pip3 &&
export PATH="$PATH:$HOME/.local/bin"
