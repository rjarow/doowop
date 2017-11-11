#!/bin/bash

# Let's go!

cd ~
if [ ! -f /usr/bin/git ];
then
    sudo apt-get install git -y
fi

if [ ! -f /usr/bin/ansible ];
then
    sudo apt install software-properties-common
    sudo add-apt-repository ppa:ansible/ansible
    sudo apt-get update
    sudo apt install ansible
fi

if [ ! -d ~/.doowop ];
then
    git clone -b dev https://github.com/rjarow/doowop.git ~/.doowop
    cd ~/.doowop
    chmod +x bootstrap_local.yml
    sudo ansible-playbook bootstrap_local.yml
fi

cd ~/.doowop
chmod +x bootstrap_local.yml
sudo ansible-playbook bootstrap_local.yml
