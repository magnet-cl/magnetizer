#!/usr/bin/env bash

set -e

function print_green() {
	echo -e "\033[32m$1\033[39m"
}

REPO='git@bitbucket.org/magnet-cl/keygen.git'
SSH_CONFIG_FILE='ssh_config'

ADD_MACOS_CONFIG_FLAG=''
IDENTITY_FILE_PATH=''

print_usage() {
	printf "Usage:
\t-m
\t\tAdds the following configuration to ssh hosts:\n
\t\t\tAddKeysToAgent yes
\t\t\tUseKeychain yes
\t\t\tIdentitiesOnly yes\n
\t\tTo ensure macos uses keychain.\n
\t-i FILE
\t\tSpecify identity file for ssh hosts.\n
"
}
while getopts 'mi:' flag; do
	case "${flag}" in
	m) ADD_MACOS_CONFIG_FLAG='true' ;;
	i) IDENTITY_FILE_PATH="${OPTARG}" ;;
	*)
		print_usage
		exit 1
		;;
	esac
done

print_green "Obtaining ssh config from keygen repository (read access required)"
git archive --remote=ssh://$REPO master $SSH_CONFIG_FILE | tar -x
mkdir -p ~/.ssh/config.d
mv -f $SSH_CONFIG_FILE ~/.ssh/config.d/magnet

if [ ! -z "$ADD_MACOS_CONFIG_FLAG" ]; then
	print_green "Adding MacOS configuration to hosts"
	perl -pi -e 's/(.*)user magnet/&\n\1AddKeysToAgent yes\n\1UseKeychain yes\n\1IdentitiesOnly yes/g' ~/.ssh/config.d/magnet
fi

if [ ! -z "$IDENTITY_FILE_PATH" ]; then
	print_green "Adding identity file to host configuration"
	perl -pi -e "s|(.*)user magnet|&\n\1IdentityFile $IDENTITY_FILE_PATH|g" ~/.ssh/config.d/magnet
fi

if grep -Fxq "Include config.d/*" ~/.ssh/config; then
	# code if found
	print_green "config.d/* already included in ssh config"
else
	# code if not found
	print_green "Including config.d/* in ssh config"
	perl -pi -e '1{h;s/.*/Include config.d\/*\n/;p;g;}' ~/.ssh/config
fi
