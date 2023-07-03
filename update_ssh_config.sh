#!/usr/bin/env bash

set -e

function print_green() {
	echo -e "\033[32m$1\033[39m"
}

REPO='git@bitbucket.org/magnet-cl/keygen.git'
SSH_CONFIG_FILE='ssh_config'
IDENTITY_FILE_PATH=''

print_usage() {
	printf "Usage:
\t-i FILE
\t\tSpecify identity file for ssh hosts.\n
"
}
while getopts 'i:' flag; do
	case "${flag}" in
	i) IDENTITY_FILE_PATH="${OPTARG}" ;;
	*)
		print_usage
		exit 1
		;;
	esac
done

print_green "Obtaining ssh config from keygen repository (read access required)"
git archive --remote=ssh://$REPO master $SSH_CONFIG_FILE | tar -x
mkdir -p $HOME/.ssh/config.d
mv -f $SSH_CONFIG_FILE $HOME/.ssh/config.d/magnet

if [[ "$OSTYPE" == "darwin"* ]]; then
	print_green "Adding MacOS configuration to hosts"
	perl -pi -e 's/(.*)user .*/$&\n\1AddKeysToAgent yes\n\1UseKeychain yes/g' $HOME/.ssh/config.d/magnet
fi

if [ ! -z "$IDENTITY_FILE_PATH" ]; then
	print_green "Adding identity file to host configuration"
	perl -pi -e "s|(.*)user magnet|\$&\n\1IdentityFile $IDENTITY_FILE_PATH\n\1IdentitiesOnly yes|g" $HOME/.ssh/config.d/magnet
fi

if [ ! -f "$HOME/.ssh/config" ]; then
	print_green "Creating ssh config"
	cat >$HOME/.ssh/config <<EOF
Include config.d/*

EOF
elif ! grep -Fxq "Include config.d/*" $HOME/.ssh/config; then
	# code if not found
	print_green "Including config.d/* in ssh config"
	echo -e "Include config.d/*\n$(cat $HOME/.ssh/config)" >$HOME/.ssh/config
else
	# code if found
	print_green "config.d/* already included in ssh config"
fi
