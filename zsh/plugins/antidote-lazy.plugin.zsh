# antidote lazy load zsh plugin
# This plugin loads antidote into the current shell

function antidote() {
  echo "🚨 antidote not loaded! Loading now..." >&2
  unset -f antidote
  source "$(brew --prefix antidote)/share/antidote/antidote.zsh"

  antidote "$@" # invoke the real function now
}
