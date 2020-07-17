# alias setup script for Ruby installed programs.
# shellcheck disable=SC2154

#export GEM_PATH=/usr/local/lib/ruby/gems/2.6.0/
#export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"

if (($+commands[rbenv])); then
	# export rbenv
	eval "$(rbenv init -)"
fi
