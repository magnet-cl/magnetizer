#!/bin/bash

set -e

function print_green(){
    echo -e "\033[32m$1\033[39m"
}

mkdir -p ~/.ssh

if ! [[ -f ~/.ssh/id_rsa.pub ]]; then
    print_green "An ssh key must be generated"
    ssh-keygen -t rsa
else
    print_green "An ssh key was found"
fi

print_green "Adding id_rsa.pub to the authorized keys"
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
