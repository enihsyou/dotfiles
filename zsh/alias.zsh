# Alias defines
# shellcheck disable=SC2139

alias ss="env HTTP_PROXY=\"http://localhost:10801\" HTTPS_PROXY=\"http://localhost:10801\" NO_PROXY=\"127.0.0.1,192.168.*,*.hypers.com,10.*\""
alias ss_r8500="env HTTP_PROXY=\"socks5://R8500:23456\" HTTPS_PROXY=\"socks5://R8500:23456\" NO_PROXY=\"127.0.0.1,192.168.*,*.hypers.com,10.*\""
alias ss_hypers="env HTTP_PROXY=\"socks5://10.0.7.80:1080\" HTTPS_PROXY=\"socks5://10.0.7.80:1080\" NO_PROXY=\"127.0.0.1,192.168.*,*.hypers.com,10.*\""
alias ss_revoke="unset HTTP_PROXY;unset HTTPS_PROXY;unset NO_PROXY"
