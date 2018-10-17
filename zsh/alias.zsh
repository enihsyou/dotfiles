alias lessjson="jq -C . | less -R"
alias finder="open $PWD"
alias revoke_proxy="unset HTTP_PROXY;unset HTTPS_PROXY"

alias ls="exa --classify --time-style=iso"
alias ll="ls --long --header"
alias lt="ls --tree"
alias la="ll --all --group"
alias laa="la --inode --links --modified --created --accessed"
alias la@="la --extended"
alias l="ls --oneline"