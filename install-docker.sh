#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

bash -c "$(curl -fsSL https://get.docker.com)"
usermod -aG docker pi
