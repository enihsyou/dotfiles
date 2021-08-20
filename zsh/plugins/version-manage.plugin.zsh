# lazy load command placeholder on zsh startup

##### nvm (node version manager) #####
# placeholder nvm shell function
# On first use, it will set nvm up properly which will replace the `nvm`
# shell function with the real one
# take from web-cache of: https://peterlyons.com/problog/2018/01/zsh-lazy-loading
function nvm() {
  unset -f nvm
  export NVM_DIR="$HOME/.nvm"
  nvm_dirs=(
    "/usr/local/opt/nvm/nvm.sh"
    "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
    "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
    "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
  )
  for dir in "${nvm_dirs[@]}"; do
  	# shellcheck source=/dev/null
  	[ -s "$dir" ] && source "$dir"
  done
  nvm "$@" # invoke the real nvm function now
}

# gvm
function gvm() {
  unset -f gvm
  gvm_dirs=(
    "$HOME/.gvm/scripts/gvm"
  )
  for dir in "${gvm_dirs[@]}"; do
  	# shellcheck source=/dev/null
  	[ -s "$dir" ] && source "$dir"
  done
  gvm "$@" # invoke the real gvm function now
}

