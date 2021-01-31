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