#!/usr/bin/env bash

# brew install secretive
secretive_agent=/Users/enihsyou/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
if [ -e $secretive_agent ]; then
    export SSH_AUTH_SOCK=$secretive_agent
fi
unset secretive_agent
