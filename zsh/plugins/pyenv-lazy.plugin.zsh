# pyenv lazy load zsh plugin
# a modified version of
# https://github.com/davidparsson/zsh-pyenv-lazy
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/pyenv/pyenv.plugin.zsh

# This plugin loads pyenv into the current shell and provides prompt info via
# the 'pyenv_prompt_info' function. Also loads pyenv-virtualenv if available.

# lazy load
pyenv() {
    echo "🚨 pyenv not loaded! Loading now..."
    unset -f pyenv # replace with actual target
    eval "$(pyenv init --path)"
    eval "$(pyenv init - --no-rehash zsh)"
    if (( $+commands[pyenv-virtualenv-init] )); then
        eval "$(pyenv virtualenv-init - zsh)"
    fi
    pyenv "$@"
}
return # prefer simpler method

# Load pyenv only if command not already available
if command -v pyenv &> /dev/null && [[ "$(uname -r)" != *icrosoft* ]]; then
    FOUND_PYENV=1
else
    FOUND_PYENV=0
fi

if [[ $FOUND_PYENV -ne 1 ]]; then
    pyenvdirs=("$HOME/.pyenv" "/usr/local/pyenv" "/opt/pyenv" "/usr/local/opt/pyenv")
    for dir in "${pyenvdirs[@]}"; do
        if [[ -d $dir/bin ]]; then
            export PATH="$PATH:$dir/bin"
            FOUND_PYENV=1
            break
        fi
    done
fi

if [[ $FOUND_PYENV -ne 1 ]]; then
    if (( $+commands[brew] )) && dir=$(brew --prefix pyenv 2>/dev/null); then
        if [[ -d $dir/bin ]]; then
            export PATH="$PATH:$dir/bin"
            FOUND_PYENV=1
        fi
    fi
fi

if [[ $FOUND_PYENV -eq 1 ]]; then
    # lazy load
    function pyenv() {
        unset -f pyenv # replace with actual target
        eval "$(pyenv init - --no-rehash zsh)"
        if (( $+commands[pyenv-virtualenv-init] )); then
            eval "$(pyenv virtualenv-init - zsh)"
        fi
        pyenv "$@"
    }
fi

unset FOUND_PYENV pyenvdirs dir
