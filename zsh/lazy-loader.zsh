# lazy load command placeholder on zsh startup

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
