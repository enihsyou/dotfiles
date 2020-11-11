listening() {
    if [ $# -eq 0 ]; then
        lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

proxy() {
    local PROXY_SERVER="http://bj-rd-proxy.byted.org:3128"
    if [[ "$1" == "on" ]]; then
        export https_proxy="$PROXY_SERVER"
        export http_proxy="$PROXY_SERVER"
        export no_proxy="*.byted.org"
        echo "Proxy On"
    else
        unset https_proxy
        unset http_proxy
        unset no_proxy
        echo "Proxy Off"
    fi
}
