# rbenv lazy load zsh plugin

# This plugin loads rbenv into the current shell

function rbenv() {
  echo "🚨 rbenv not loaded! Loading now..."
  unset -f rbenv
  eval "$(command rbenv init -)"
  rbenv "$@"
}
