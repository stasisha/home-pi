#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# Install needed Home Assistant Supervised dependencies
# TODO findout when needReboot
if ! dpkg -s network-manager &> /dev/null
then
    apt-get install network-manager -y
    needReboot='y'
fi

if ! dpkg -s apparmor-utils &> /dev/null
then
    apt-get install apparmor-utils -y
    needReboot='y'
fi

if ! jq -s apparmor-utils &> /dev/null
then
    apt-get install jq -y
    needReboot='y'
fi

if [ "$needReboot" == 'y' ]; then
    reboot
fi

cp /etc/network/interfaces /etc/network/interfaces.original.bk

curl -Lo installer.sh https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh
bash installer.sh --machine raspberrypi4
rm -r installer.sh
