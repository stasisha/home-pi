#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/stasisha/bash-utils/master/file-edit.sh)";


replace "defaults.ctl.card 0" "defaults.ctl.card 1" "/usr/share/alsa/alsa.conf"
replace "defaults.pcm.card 0" "defaults.pcm.card 1" "/usr/share/alsa/alsa.conf"

curl -sSL https://install.ledfx.app/ | bash

