# rbenv lazy load zsh plugin

# This plugin loads rbenv into the current shell

function rbenv() {
  echo "🚨 rbenv not loaded! Loading now..."
  unset -f rbenv
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
  eval "$(command rbenv init -)"
  rbenv "$@"
}
