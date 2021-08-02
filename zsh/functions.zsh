# define custom functions which can be used in shell(specifically zsh) runtime.

listening() {
    if [ $# -eq 0 ]; then
        lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

# add entry to PATH only if not present.
# credit: https://unix.stackexchange.com/a/14898
function path_add() {
    case ":${PATH:=$1}:" in
      *:"$1":*) ;;
      *) PATH="$1:$PATH" ;;
    esac
}

# remove duplicate PATH entries
# credit: https://unix.stackexchange.com/a/325729
# shellcheck disable=SC2034
function path_dedup() {
    # The lower-case version of PATH is an array parameter
    # bound to the scalar upper-case parameter
    # https://www.zsh.org/mla/users/2015/msg00178.html
    typeset -gU path
}
