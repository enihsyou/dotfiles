# alias setup script for Ruby installed programs.
# shellcheck disable=SC2154

#export GEM_PATH=/usr/local/lib/ruby/gems/2.6.0/
#export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"

rbenv() {
  echo "🚨 rbenv not loaded! Loading now..."
  unset -f rbenv
  eval "$(command rbenv init -)"
  rbenv "$@"
}
