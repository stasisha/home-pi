#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

read -r -p 'Would you like to install RaspAP (docker)? [y/n]: ' raspapDocker
read -r -p 'Would you like to configure network? [y/n]: ' configureNetwork

source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/stasisha/bash-utils/master/file-edit.sh)";


if [ "$raspapDocker" == 'y' ] || [ "$raspapDocker" == 'Y'  ]; then
    docker run --name raspap -it -d --restart unless-stopped --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN jrcichra/raspap-docker
    docker exec -it raspap bash ./setup.sh
    docker restart raspap
fi

if [ "$configureNetwork" == 'y' ] || [ "$configureNetwork" == 'Y'  ]; then
    apt install netfilter-persistent -y
    # allow internet access 
    curl "https://raw.githubusercontent.com/stasisha/home-pi/main/startup-rasp-ap.sh" -o "/etc/init.d/startup-rasp-ap.sh"
    chmod +x /etc/init.d/startup-rasp-ap.sh
    rm -f /etc/rc3.d/startup-rasp-ap
    ln -s /etc/init.d/startup-rasp-ap.sh /etc/rc3.d/S99startup-rasp-ap
    sh /etc/init.d/startup-rasp-ap.sh

    # routing traffic between networks
    addLineToBottomIfNotExists "net.ipv4.conf.all.forwarding=1" "/etc/sysctl.conf"
    
    addLineToBottomIfNotExists "country=US" "/etc/wpa_supplicant/wpa_supplicant.conf"
    
    nmcli dev set wlan0 managed no
fi
