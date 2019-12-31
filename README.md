# magnetizer
This repository is a collection of useful Ansible playbooks and roles.

## Quickstart
The `quickstart.sh` script installs pip (python 3) and the following python packages:

* ansible
* ansible-lint
* paramiko

Once `ansible` is available, the ansible galaxy roles specified on
[requirements.yml](requirements.yml) are installed (git is required to use
role versions).

## Playbooks

### vps init

The playbook is at [playbooks/vps_init.yml](playbooks/vps_init.yml).

It includes the following tasks:

* Add user to set as admin on the target host.
* Add list of ssh public keys to the authorized keys (admins).
* Set default locale (`en_US.UTF-8`).
* Install [recommended packages](playbooks/roles/common/defaults/main.yml).
* Setup NTP.
* Set swap partition
* Install zsh, oh-my-zsh and custom plugins.
* Install node.js (LTS).
* Install vim and [vim_config](https://github.com/magnet-cl/Vim_config).

The last post-task defined in the playbook upgrades system packages through
apt safe upgrade, it might require a system reboot.
