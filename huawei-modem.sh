#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

#Bus 001 Device 007: ID 12d1:1f01

apt install usb-modeswitch usb-modeswitch-data


cat <<'EOF' > /etc/usb_modeswitch.d/12d1:1f01
# Huawei E3531 modem mode
TargetVendor=0x12d1
TargetProduct=0x1f01 

MessageContent="55534243123456780000000000000011062000000100000000000000000000"
NoDriverLoading=1
EOF
