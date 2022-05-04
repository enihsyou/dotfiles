# zsh alias

# ref: https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Browsers
alias safari='/Applications/Safari.app/Contents/MacOS/Safari'
alias chrome='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

# IP addresses
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
