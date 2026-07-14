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
    print_green "Installing virtualenv"
    pip3 install virtualenv

    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    PYTHON_PATH="$HOME/Library/Python/$PYTHON_VERSION/bin"
    ZSHRC="$HOME/.zshrc"

    # Check if path is already in .zshrc
    if ! grep -qs "$PYTHON_PATH" "$ZSHRC"; then
      echo "Adding Python user path to .zshrc..."
      echo "export PATH=\"$PYTHON_PATH:\$PATH\"" >> "$ZSHRC"
      echo "Added: export PATH=\"$PYTHON_PATH:\$PATH\""
      source "$ZSHRC"
    fi
else
    print_green "Installing pip and virtualenv"
    sudo apt update
    sudo apt install --yes python3-pip virtualenv
fi

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
