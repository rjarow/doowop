#!/bin/bash

# Let's go!
### Location to install doowop ( defaults to /opt/doowop )

INSTALLDIR=/opt/doowop

### Pre-Requisites
sudo apt install software-properties-common git -y

### We need latest Ansible
sudo add-apt-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt install ansible -y



if [ ! -d ${INSTALLDIR} ];
then
    sudo git clone https://github.com/rjarow/doowop.git $INSTALLDIR
    cd ${INSTALLDIR}
    sudo chmod +x ${INSTALLDIR}/bootstrap.yml
    sudo ansible-playbook ${INSTALLDIR}/bootstrap.yml
else
    cd ${INSTALLDIR}
    sudo git pull
    sudo chmod +x ${INSTALLDIR}/bootstrap.yml
    sudo ansible-playbook ${INSTALLDIR}/bootstrap.yml
fi
