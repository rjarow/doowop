#!/bin/bash
### doowop deploy

if [ ! -f /usr/bin/ansible ]
then
    sudo apt-get install ansible -y
fi
ansible-playbook ~/.doowop/bootstrap_local.yml