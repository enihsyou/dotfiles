function install_prompt() {
    read -q "?$1 Continue (Y/n)?" 
}

# Check the Existence of a Command in Bash and Zsh
# https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/
function exist() {
    (( $+commands["$1"] )) &>/dev/null
}