alias lessjson="jq -C . | less -R"
alias finder="open ${1-`PWD`}"

alias ls="exa --classify --time-style=iso"
alias ll="ls --long --header"
alias lt="ls --tree"
alias la="ll --all --group"
alias laa="la --inode --links --modified --created --accessed"
alias la@="la --extended"
alias l="ls --oneline"

alias ss="env HTTP_PROXY=\"http://localhost:10801\" HTTPS_PROXY=\"http://localhost:10801\" NO_PROXY=\"localhost,127.0.0.1,master,*.hypers.com,10.*\""
alias revoke_proxy="unset HTTP_PROXY;unset HTTPS_PROXY"

alias java8="env JAVA_HOME=$(/usr/libexec/java_home -v1.8)"
alias java11="env JAVA_HOME=$(/usr/libexec/java_home -v11)"

alias node8="env PATH=\"/usr/local/opt/node@8/bin:$PATH\""
