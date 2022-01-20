#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

wait-for-it() {
  printf "Waiting for Home Assistant ready."
  IP_ADDRESS=$(hostname -I | awk '{ print $1 }')
  until curl --output /dev/null --silent --head --fail http://"${IP_ADDRESS}":8123; do
    printf '.'
    sleep 1
  done
}


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

if ! dpkg -s jq &> /dev/null
then
    apt-get install jq -y
    needReboot='y'
fi


if [ "$needReboot" == 'y' ]; then
    reboot
fi


# Foolow the instruction https://github.com/home-assistant/supervised-installer
apt-get install \
jq \
wget \
curl \
udisks2 \
libglib2.0-bin \
network-manager \
dbus -y

# install docker
if ! dpkg -s docker-ce &> /dev/null
then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/stasisha/home-pi/master/install-docker.sh)"
fi

# OS agent
MACHINE_TYPE=$(uname -m)
if [ ${MACHINE_TYPE} == 'armv7l' ]; then
    wget https://github.com/home-assistant/os-agent/releases/download/1.2.2/os-agent_1.2.2_linux_armv7.deb
    dpkg -i os-agent_1.2.2_linux_armv7.deb
else
    wget https://github.com/home-assistant/os-agent/releases/download/1.2.2/os-agent_1.2.2_linux_aarch64.deb
    dpkg -i os-agent_1.2.2_linux_aarch64.deb
fi

# Test os agent
gdbus introspect --system --dest io.hass.os --object-path /io/hass/os

# Home assistant
wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
dpkg -i homeassistant-supervised.deb

wait-for-it
