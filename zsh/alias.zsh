# Alias defines
# shellcheck disable=SC2139

alias lessjson="jq -C . | less -R"

alias ls="exa --classify --time-style=iso"
alias ll="ls --long --header"
alias lt="ls --tree"
alias la="ll --all --group"
alias laa="la --inode --links --modified --created --accessed"
alias la@="la --extended"
alias l="ls --oneline"

alias ss="env HTTP_PROXY=\"http://localhost:10801\" HTTPS_PROXY=\"http://localhost:10801\" NO_PROXY=\"127.0.0.1,192.168.*,*.hypers.com,10.*\""
alias ss_aaex="env HTTP_PROXY=\"http://localhost:10701\" HTTPS_PROXY=\"http://localhost:10701\" NO_PROXY=\"127.0.0.1,192.168.*,*.hypers.com,10.*\""
alias ss_r8500="env HTTP_PROXY=\"socks5://R8500:23456\" HTTPS_PROXY=\"socks5://R8500:23456\" NO_PROXY=\"127.0.0.1,192.168.*,*.hypers.com,10.*\""
alias ss_hypers="env HTTP_PROXY=\"socks5://10.0.7.80:1080\" HTTPS_PROXY=\"socks5://10.0.7.80:1080\" NO_PROXY=\"127.0.0.1,192.168.*,*.hypers.com,10.*\""
alias ss_revoke="unset HTTP_PROXY;unset HTTPS_PROXY;unset NO_PROXY"


alias node8="env PATH=\"/usr/local/opt/node@8/bin:$PATH\""

alias dk='docker'

linuxSpecific() {
    echo
}

darwinSpecific() {
    alias java8="env JAVA_HOME=$(/usr/libexec/java_home -v1.8)"
    alias java11="env JAVA_HOME=$(/usr/libexec/java_home -v11)"
}

case $(uname) in
    Linux*)  linuxSpecific;;
    Darwin*) darwinSpecific;;
    *) echo "Unsupported OS type" >&2
esac
