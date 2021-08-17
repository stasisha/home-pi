#!/bin/bash

#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

## add required functions
source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/stasisha/bash-utils/master/file-edit.sh)";
source /dev/stdin <<< "$(curl -fsSL https://raw.githubusercontent.com/stasisha/bash-utils/master/error.sh)";

source /etc/os-release
read -p 'Would you like to install the latest versions of all the previously installed packages. Reboot required. [y/n]: ' upgradePackages

if [ "$upgradePackages" != 'y' ] || [ "$upgradePackages" != 'Y' ]; then
    read -p 'Would you like to install Docker? [y/n]: ' docker
    read -p 'Would you like to install ctop? [y/n]: ' ctop
    read -p 'Would you like to install RaspAP? [y/n]: ' raspap
    read -p 'Would you like to install Home Assistant? [y/n]: ' homeAssistant
    read -p 'Would you like to install Network Manager? Reboot required. [y/n]: ' networkManager
fi

if [[ "$ID" == "raspbian"* ]]; then
    read -p 'Would you like use University of Oxford Mirror? [y/n]: ' oxfordMirror
    
    if [ "$oxfordMirror" == 'y' ] || [ "$oxfordMirror" == 'Y' ]; then
        #https://www.raspbian.org/RaspbianMirrors
        local sourcesList="/etc/apt/sources.list"
        mv "${sourcesList}" "${sourcesList}.original.bk"
        touch "/etc/apt/sources.list"
        addLineToBottomIfNotExists "deb http://mirror.ox.ac.uk/sites/archive.raspbian.org/archive/raspbian buster main contrib non-free rpi" "${sourcesList}"
    fi
#TODO check condition debian
elif [[ "$OSTYPE" == "debian"* ]]; then
    #placeholder
    echo "debian os";
else
    echoError "Unsupported OS";
    return 1
fi

if [  "$upgradePackages" == 'y' ] || "$upgradePackages" == 'Y' || "$oxfordMirror" == 'y' ] || "$oxfordMirror" == 'Y']; then
    apt-get update
else
    read -p 'Would you like to install the latest versions of update package database. [y/n]: ' upgradePackageDatabase
fi


if [ "$upgradePackageDatabase" == 'y' || [ "$upgradePackageDatabase" == 'Y']; then
    apt-get update
fi

if [ "$upgradePackages" == 'y' ] || [ "$upgradePackages" == 'Y' ]; then
    apt-get upgrade
    sudo reboot
fi

if [ "$ctop" == 'y' ] || [ "$ctop" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-ctop.sh)"
fi

if [ "$raspap" == 'y' ] || [ "$raspap" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-raspap.sh)"
fi

if [ "$docker" == 'y' ] || [ "$docker" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-docker.sh)"
fi

if [ "$homeAssistant" == 'y' ] || [ "$homeAssistant" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-home-assistant.sh)"
fi

if [ "$networkManager" == 'y' ] || [ "$networkManager" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-network-manager.sh)"
fi


