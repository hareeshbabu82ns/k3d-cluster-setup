* setup ssh key login
```sh
$> ssh-copy-id user@utmp
```
* install `ansible` and create `hosts` file and `playbooks`
* running simple commands
```sh
$> ansible all -a "cat /etc/hosts"
```
* running a playbook
```sh
$> ansible-playbook ./playbooks/apt.yml -i ./inventory/hosts --ask-become-pass
$> ansible-playbook site.yml --tags="test1,test2"
```
* using valult
```sh
$> ansible-vault encrypt ./inventory/group_vars/kubes/vault.yml --vault-pass-file vault.pass
$> ansible-vault decrypt ./inventory/group_vars/kubes/vault.yml --vault-pass-file vault.pass
```
* create `vault.pass` with password of the vault
* running a playbook using vault pass
```sh
$> ansible-playbook ./playbooks/apt.yml --ask-vault-pass
$> ansible-playbook ./playbooks/apt.yml --vault-pass-file vault.pass
```

* running roles
```sh
$> ansible-playbook site.yml --vault-pass-file vault.pass
$> ansible-playbook reset.yml --vault-pass-file vault.pass
```

* adding `kubernetes` community collection
```sh
$> ansible-galaxy collection install community.kubernetes

```

## Setup
* create RSA SSH key
```sh
$> ssh-keygen -t RSA -b 4096
$> ssh-copy-id user@remote
```

* create `vault.pass` with vault password
* install ansible dependencies
```sh
$> sudo apt install ansible

$> ansible-galaxy collection install community.kubernetes
# for docker
$> ansible-galaxy collection install community.general
```

* build cluster
```sh
$> ansible-playbook site.yml
# just to re-build cluster
$> ansible-playbook site.yml --tags "k3d"
# to fetch updated kubeconfig
$> ansible-playbook site.yml --tags "fetch-config"
# delete cluster
$> ansible-playbook reset.yml
```
