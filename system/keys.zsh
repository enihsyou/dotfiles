# Pipe my public key to my clipboard.
[[ -n "$public_key_name" ]] || public_key_name=id_rsa.pub
alias pubkey="more ~/.ssh/$public_key_name | pbcopy | echo '=> Public key named [$public_key_name] copied to pasteboard.'"
