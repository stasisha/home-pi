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

if [ "$upgradePackages" == 'y' ] || [ "$upgradePackages" == 'Y' ]; then

    # skip additional reboot 
    read -p 'Would you like to install Home Assistant requirments? [y/n]: ' useHomeAssistant

    apt update
    if [ "$useHomeAssistant" == 'y' ] || [ "$useHomeAssistant" == 'Y' ]; then
         apt-get install network-manager apparmor-utils jq -y
    fi
    apt upgrade -y
    echo "Upgrade completed."
    echo "Reboot..."
    reboot
fi
 
read -p 'Would you like to install Docker? [y/n]: ' docker
read -p 'Would you like to install ctop? [y/n]: ' ctop
read -p 'Would you like to install PulseAudio Volume Control? [y/n]: ' pavucontrol
read -p 'Would you like to install Home Assistant? [y/n]: ' homeAssistant
#read -p 'Would you like to install Network Manager? [y/n]: ' networkManager
read -p 'Would you like to install LedFX? [y/n]: ' ledfx
read -p 'Would you like to use RaspAP? [y/n]: ' raspap

if [[ "$ID" == "raspbian"* ]]; then
    read -p 'Would you like use University of Oxford Mirror? [y/n]: ' oxfordMirror
    
    if [ "$oxfordMirror" == 'y' ] || [ "$oxfordMirror" == 'Y' ]; then
        #https://www.raspbian.org/RaspbianMirrors
        sourcesListFile="/etc/apt/sources.list"
        mv "${sourcesListFile}" "${sourcesListFile}.original.bk"
        touch "/etc/apt/sources.list"
        addLineToBottomIfNotExists "deb http://mirror.ox.ac.uk/sites/archive.raspbian.org/archive/raspbian buster main contrib non-free rpi" "${sourcesListFile}"
    fi
#TODO check condition debian
elif [[ "$OSTYPE" == "debian"* ]]; then
    #placeholder
    echo "debian os";
else
    echoError "Unsupported OS";
    return 1
fi


if [ "$raspap" == 'y' ] || [ "$raspap" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-raspap.sh)"
fi

if [ "$pavucontrol" == 'y' ] || [ "$pavucontrol" == 'Y' ]; then
    apt update
    apt install pavucontrol paprefs -y
fi

if [ "$ctop" == 'y' ] || [ "$ctop" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-ctop.sh)"
fi

if [ "$docker" == 'y' ] || [ "$docker" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-docker.sh)"
fi

if [ "$networkManager" == 'y' ] || [ "$networkManager" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-network-manager.sh)"
fi

if [ "$ledFx" == 'y' ] || [ "$ledFx" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-led-fx.sh)"
fi

if [ "$homeAssistant" == 'y' ] || [ "$homeAssistant" == 'Y'  ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-home-assistant.sh)"
fi

echo "All selected applications were installed."
