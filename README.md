# magnetizer
This repository is a collection of useful Ansible playbooks and roles.

- [magnetizer](#magnetizer)
  * [Quickstart](#quickstart)
  * [Inventory](#inventory)
    + [host_list plugin](#host-list-plugin)
  * [Playbooks](#playbooks)
    + [vps init](#vps-init)
      - [Notes on servers providers](#notes-on-servers-providers)
        * [AWS EC2](#aws-ec2)
        * [DigitalOcean](#digital-ocean)
    + [developer](#developer)
    + [enable SSL](#enable-ssl)
    + [install vim config](#install-vim-config)
    + [install zsh](#install-zsh)
    + [secure ssh](#secure-ssh)
    + [authorize ssh key](#authorize-ssh-key)
    + [DigitalOcean playbooks](#digitalocean-playbooks)
      - [create droplet](#create-droplet)
      - [create A record](#create-a-record)
      - [list domain records](#list-domain-records)
      - [delete DNS record](#delete-dns-record)
    + [AWS playbooks](#aws-playbooks)
      - [create A record](#create-a-record)

## Quickstart
The `quickstart.sh` script installs pip (python 3) and the following python packages:

* ansible
* ansible-lint
* paramiko

Once `ansible` is available, the ansible galaxy roles specified on
[requirements.yml](requirements.yml) are installed (git is required to use
role versions).

The `init_ssh_key.sh` script generates an SSH key (if the default pub key is
not present), then adds it to the authorized keys of the current user.

## Inventory
An [inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
must be defined to select the hosts you want `ansible` to run against.

The `update_ssh_config.sh` script downloads the inventory plugin
[ssh_config.py](https://raw.githubusercontent.com/ansible/ansible/stable-2.9/contrib/inventory/ssh_config.py),
then it obtains the `ssh_config` file from magnet's keygen repository and
it merges with `~/.ssh/config_local` into `~/.ssh/config`. This allows the
following syntax when running a playbook:

`ansible-playbook -i inventory -l <host> playbooks/<playbook_name.yml>`

For example, consider the following host defined at the ssh config file:
```
Host magnetizer.staging
    hostname magnetizer-stg.magnet.cl
    user magnet
```
To secure SSH you can run the following playbook:

`ansible-playbook -i inventory -l magnetizer.staging playbooks/secure_ssh.yml`

### host_list plugin
With the
[host_list](https://docs.ansible.com/ansible/latest/plugins/inventory/host_list.html)
plugin a host can be set as command argument.

Following the host defined on the previous example, the playbook can be run with:

`ansible-playbook -i 'magnet@magnetizer-stg.magnet.cl,' playbooks/secure_ssh.yml`


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

#### Notes on servers providers
##### AWS EC2
Within the EC2 instance creation an SSH key must be selected and usually is
not loaded on the agent running the playbook, there are two alternatives:

1. Add the key selected on aws to the ssh agent: `ssh-add <aws-key.pem>`
2. Use `--private-key` with `ansible-playbook`:

`ansible-playbook -i inventory -l magnetizer.ec2 playbooks/vps.init.yml
--private-key ~/.ssh/aws-key.pem`

##### DigitalOcean
The latest Ubuntu Server 18.04 droplet available on Digital Ocean requires a
system reboot after upgrading all system packages.

### developer

The playbook is at [playbooks/developer.yml](playbooks/developer.yml).

It includes the following roles considering localhost as target:

* common/main
* zsh
* node
* vim

Since the target is localhost, the playbook can be run without specifying an
inventory:

`ansible-playbook playbooks/developer.yml`

If the user needs a password to run `sudo`, the following option enables
privilege escalation:

`ansible-playbook playbooks/developer.yml --ask-become-pass`

### enable SSL

The playbook is at [playbooks/enable_ssl.yml](playbooks/enable_ssl.yml), it
automatically enable HTTPS on the target host through
[certbot](https://certbot.eff.org/).

The following variables can be set as extra parameters when the playbook is
played:

* `certbot_domain`: Comma-separated list of domains to obtain a certificate.
  If unset it will use the host specified in the ansible inventory.
* `certbot_admin_email`: Email for account notifications.

A related playbook is at
[playbooks/secure_nginx.yml](playbooks/secure_nginx.yml), it hardens nginx
through a galaxy role from https://dev-sec.io/.

### install vim config

The playbook is at
[playbooks/install_vim_config.yml](playbooks/install_vim_config.yml).

### install zsh

The playbook is at [playbooks/install_zsh.yml](playbooks/install_zsh.yml).

It performs the following tasks:

* Install zsh and oh-my-zsh through the ansible galaxy role
[gantsign.oh-my-zsh](https://galaxy.ansible.com/gantsign/oh-my-zsh).
* Upload and set custom set of plugins.

### secure ssh

The playbook is at [playbooks/secure_ssh.yml](playbooks/secure_ssh.yml).

It hardens SSH through a galaxy role from https://dev-sec.io/. Custom
configurations are set as [role
variables](playbooks/roles/ssh/defaults/main.yml).

### authorize ssh key

The playbook is at
[playbooks/authorize_ssh_key.yml](playbooks/authorize_ssh_key.yml).

It prompts for a magnet user to obtain its github username from the [intranet
platform](https://intranet.magnet.cl). Then uses
`https://github.com/<username>.keys` as key parameter on the [authorized key
module](https://docs.ansible.com/ansible/latest/modules/authorized_key_module.html)
of `ansible`.

### DigitalOcean playbooks
In order to use these playbooks, the environment variable
`DIGITALOCEAN_ACCESS_TOKEN` must be set.

#### create droplet

The playbook is at
[playbooks/do_create_droplet.yml](playbooks/do_create_droplet.yml), it
requires the official command line interface for the DigitalOcean API
[doctl](https://github.com/digitalocean/doctl).

It creates a DigitalOcean droplet and register a DNS record to the obtained
IP.

The following variables can be set as extra parameters when the playbook is
played:

* `hostname`: This variable is mandatory (example: "demo.do.magnet.cl").
* `do_size`: Slug for the droplet size, the default value is `s-1vcpu-1gb`.
  The slugs can be listed with `doctl compute size list`.
* `do_region`: Slug for the region, the default value is `nyc3`. The slugs can
  be listed with `doctl compute region list`
* `do_image`: Slug for the droplet image, the default value is
  `ubuntu-18-04-x64`. The slugs can be listed with `doctl compute image list`.
* `do_base_domain`: Base domain for the DNS record, the default value is
`do.magnet.cl`.

#### create A record

The playbook is at
[playbooks/do_create_a_record.yml](playbooks/do_create_a_record.yml), it
requires the official command line interface for the DigitalOcean API
[doctl](https://github.com/digitalocean/doctl).

It will prompt for:

* `domain`: The default value is `do.magnet.cl`.
* `hostname`: The record, for example `demo`.
* `ip`: The IP for the record.

#### list domain records

The playbook is at
[playbooks/do_list_domain_records.yml](playbooks/do_list_domain_records.yml), it
requires the official command line interface for the DigitalOcean API
[doctl](https://github.com/digitalocean/doctl).

It will prompt for:

* `domain`: The default value is `do.magnet.cl`.

#### delete DNS record

The playbook is at
[playbooks/do_delete_dns_record.yml](playbooks/do_delete_dns_record.yml), it
requires the official command line interface for the DigitalOcean API
[doctl](https://github.com/digitalocean/doctl).

It will prompt for:

* `domain`: The default value is `do.magnet.cl`.
* `record id`: The record id to be deleted, can be obtained with [list domain
  records](#list-domain-records).

### AWS playbooks
In order to use these playbooks, the AWS access and secret keys must be set
through a [boto
configuration](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html#configuration)
or with the following environment variables:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

#### create A record

The playbook is at
[playbooks/r53_create_a_record.yml](playbooks/r53_create_a_record.yml), it
requires `boto` (ideally the
[route53](https://docs.ansible.com/ansible/latest/modules/route53_module.html)
module will use `boto3` as other modules are already doing it).

It will prompt for:

* `zone`: The default value is `aws.magnet.cl`.
* `name`: The record, for example `demo`.
* `ip`: The IP for the record.
