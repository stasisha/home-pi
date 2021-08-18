#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

if ! dpkg -s docker-ctop &> /dev/null
then
    echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
    wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
    apt update
    apt install docker-ctop
else
    echo "docker-ctop is already installed. Nothing to do."
fi
