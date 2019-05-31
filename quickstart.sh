#!/bin/bash

set -e

function print_green(){
    echo -e "\e[32m$1\e[39m"
}

print_green "Adding ansible PPA"
sudo apt install software-properties-common
sudo apt-add-repository --yes ppa:ansible/ansible
sudo apt update

print_green "Installing ansible"
sudo apt install --yes ansible

print_green "Setting hosts configuration file at ~/.ansible/hosts"
echo "[defaults]" >> ~/.ansible.cfg
echo "inventory = ~/.ansible/hosts" >> ~/.ansible.cfg
mkdir -p ~/.ansible
print_green "Adding localhost to ansible hosts"
echo "localhost" >> ~/.ansible/hosts
