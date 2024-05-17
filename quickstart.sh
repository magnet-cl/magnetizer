#!/bin/bash

set -e

function print_green(){
    echo -e "\033[32m$1\033[39m"
}

case "$(uname -s)" in

   Darwin)
     OS='Darwin'
     ;;

   Linux)
     OS='Linux'
     ;;

   *)
    echo "OS not supported"
    exit
    ;;
esac

if [ "$OS" == "Darwin" ] ; then
    print_green "Installing ansible"
    pip3 install --user ansible-core ansible-lint paramiko

    print_green "Installing ansible-galaxy requirements"
    ansible-galaxy install -r requirements.yml --force

    print_green "Remember to add the binary folder that contains ansible to PATH"
    ansible_path=$(pip3 show ansible | grep "Location.*lib" -o)
    location=${ansible_path//\/lib/\/bin}
    location=${location//Location: /}
    print_green "Include the following line in your shell dotfile (may be ~/.zshrc or ~/.bash_profile):"
    print_green "export PATH=\$PATH:$location"
    echo ""

else
    print_green "Installing pip and virtualenv"
    sudo apt update
    sudo apt install --yes python3-pip virtualenv

    print_green "Creating virtualenv"
    virtualenv .env
    source .env/bin/activate

    print_green "Installing ansible"
    pip install ansible-core ansible-lint paramiko jmespath

    print_green "Installing ansible-galaxy requirements"
    ansible-galaxy install -r requirements.yml --force

    print_green "To create droplets install digital ocean cli with sudo snap install doctl"

    print_green "To enable the created virtualenv run:"
    print_green "source .env/bin/activate"

fi
