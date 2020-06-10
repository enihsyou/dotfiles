# alias setup script for YARN installed programs.
# shellcheck disable=SC2154

if (( $+commands[nali] )); then
	# loading 'nali-cli' alias
	alias dig='nali-dig'
	alias nslookup='nali-nslookup'
	alias traceroute='nali-traceroute'
fi
