# alias setup script for brew installed programs.

# jq
alias lessjson="jq -C . | less -R"

# exa
# https://the.exa.website/docs/colour-themes
if ! is_system_appearence_dark; then
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
if ! is_system_appearence_dark; then
	# export BAT_THEME="GitHub"
	alias fd="LS_COLORS="$(vivid generate ayu)" fd"
fi

# bat
if ! is_system_appearence_dark; then
	# export BAT_THEME="GitHub"
	alias bat="BAT_THEME='GitHub' bat"
else
	# export BAT_THEME="Visual Studio Dark+"
	alias bat="BAT_THEME='Visual Studio Dark+' bat"
fi

# duf
alias df="duf"

# dust
alias du="dust"

# dog
alias dig="dog"
