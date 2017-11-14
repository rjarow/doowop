#!/bin/bash

# Let's go!
### Location to install doowop ( defaults to /opt/doowop )
INSTALLDIR=/opt/doowop

### Pre-Requisites - We need latest version of ansible from PPA
sudo apt-get install git -y
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ansible/ansible
sudo apt-get update
sudo apt install ansible -y



if [ ! -d ${INSTALLDIR} ];
then
    git clone -b dev https://github.com/rjarow/doowop.git $INSTALLDIR
    cd ${INSTALLDIR}
    chmod +x bootstrap_local.yml
    sudo ansible-playbook bootstrap_local.yml
else
    cd ${INSTALLDIR}
    git pull
    chmod +x bootstrap_local.yml
    sudo ansible-playbook bootstrap_local.yml
fi
