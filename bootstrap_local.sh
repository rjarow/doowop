#!/bin/bash
### doowop deploy

if [ ! -f /usr/bin/ansible ];
then
    sudo apt install software-properties-common && /
    sudo add-apt-repository ppa:ansible/ansible && /
    sudo apt-get update && /
    sudo apt install ansible

fi
sudo ansible-playbook ~/.doowop/bootstrap_local.yml