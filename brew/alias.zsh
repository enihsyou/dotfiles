# alias setup script for brew installed programs.

# jq
alias lessjson="jq -C . | less -R"

# exa
alias ls="exa --classify --time-style=iso"
alias ll="ls --long --header"
alias lt="ls --tree"
alias la="ll --all --group"
alias laa="la --inode --links --modified --created --accessed"
alias la@="la --extended"
alias l="ls --oneline"

# node@8
#alias node8="env PATH=\"/usr/local/opt/node@8/bin:$PATH\""
