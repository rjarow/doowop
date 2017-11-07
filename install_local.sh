#!/bin/bash

# Let's go!

cd ~
if [ ! -f /usr/bin/git ]
then
    sudo apt-get install git -y
fi

git clone -b dev https://github.com/rjarow/doowop.git ~/.doowop
cd ~/.doowop
chmod +x bootstrap_local.sh && bootstrap_local.sh