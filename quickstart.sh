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
    pip3 install --user ansible

    print_green "Remember to add the binary folder that contains ansible to PATH"
    ansible_path=`pip3 show ansible | grep "Location.*lib" -o`
    location=${ansible_path//\/lib/\/bin}
    location=${location//Location: /}
    print_green "Include the following line in your shell dot file:"
    print_green "export PATH=\$PATH:$location"
    echo ""

else
    print_green "Adding ansible PPA"
    sudo apt install software-properties-common
    sudo apt-add-repository --yes ppa:ansible/ansible
    sudo apt update

    print_green "Installing ansible"
    sudo apt install --yes ansible
fi

print_green "Setting hosts configuration file at ~/.ansible/hosts"
echo "[defaults]" >> ~/.ansible.cfg
echo "inventory = ~/.ansible/hosts" >> ~/.ansible.cfg
mkdir -p ~/.ansible
print_green "Adding localhost to ansible hosts"
echo "localhost" >> ~/.ansible/hosts
