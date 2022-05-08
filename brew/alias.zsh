# alias setup script for brew installed programs.

# jq
alias lessjson="jq -C . | less -R"

# exa
# https://the.exa.website/docs/colour-themes
if ! declare -f is_system_appearence_dark > /dev/null; then
	true
elif ! is_system_appearence_dark; then
	alias exa='EXA_COLORS="sn=34:sb=1;32" exa'
fi
alias ls="exa --classify --time-style=iso --colour-scale"
alias ll="ls --long --header"
alias lt="ls --tree"
alias la="ll --all --group"
alias laa="la --inode --links --modified --created --accessed"
alias la@="la --extended"
alias l="ls --oneline"

# fd
if ! declare -f is_system_appearence_dark > /dev/null; then
	true
elif ! is_system_appearence_dark; then
	# cost is negligible, expand when used
	alias fd='LS_COLORS=$(vivid generate ayu) fd'
fi

# duf
alias df="duf"

# dust
alias du="dust"

# dog
alias dig="dog"

# tldr
alias tldr="tldr --theme base16"
