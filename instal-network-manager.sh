#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

## add required functions
source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/stasisha/bash-utils/master/file-edit.sh)";

apt update
apt install network-manager network-manager-gnome

addLineToBottomIfNotExists "denyinterfaces wlan0" "/etc/dhcpcd.conf"

addLineToBottomIfNotExists "[ifupdown]" "/etc/dhcpcd.conf"
addLineToBottomIfNotExists "managed=true" "/etc/dhcpcd.conf"

replace "/etc/NetworkManager/NetworkManager.conf" "plugins=keyfile" "plugins=ifupdown,keyfile"

reboot
