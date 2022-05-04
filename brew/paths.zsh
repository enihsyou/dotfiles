# Export brew installed software into PATH

if (( $+commands[brew] )); then
    # export brew linked binary, but local bin take precedence
    export PATH="$HOME/.local/bin:/usr/local/sbin:$PATH"

    # export brew installed nodejs home
    [ -L /usr/local/opt/node ] && export NODEJS_HOME="/usr/local/opt/node"
    # export brew installed yarn home
    [ -L /usr/local/opt/yarn ] && export YARN_HOME="/usr/local/opt/yarn"
fi
