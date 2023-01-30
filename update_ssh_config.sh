#!/bin/bash

set -e

function print_green() {
	echo -e "\033[32m$1\033[39m"
}

REPO='git@bitbucket.org/magnet-cl/keygen.git'
SSH_CONFIG_FILE='ssh_config'

print_green "Obtaining ssh config from keygen repository (read access required)"
git archive --remote=ssh://$REPO master $SSH_CONFIG_FILE | tar -x
mv -f $SSH_CONFIG_FILE ~/.ssh/config_magnet

print_green "Custom configuration or hostnames must be set on ~/.ssh/config_local"
touch ~/.ssh/config_local

print_green "Merging local ssh config with magnet"
cat ~/.ssh/config_magnet ~/.ssh/config_local > ~/.ssh/config
