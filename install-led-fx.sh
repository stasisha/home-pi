#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

sed -i  "s/defaults.ctl.card 0/defaults.ctl.card 1/g" "/usr/share/alsa/alsa.conf"
sed -i  "s/defaults.pcm.card 0/defaults.pcm.card 1/g" "/usr/share/alsa/alsa.conf"

curl -sSL https://install.ledfx.app/ | bash

