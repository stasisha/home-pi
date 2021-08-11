#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# Install needed Home Assistant Supervised dependencies
sudo apt-get install network-manager apparmor-utils jq -y

sudo reboot

cp /etc/network/interfaces /etc/network/interfaces.original.bk

curl -Lo installer.sh https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh
bash installer.sh --machine raspberrypi4
rm -r installer.sh
