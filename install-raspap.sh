#!/bin/bash

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

sudo apt install netfilter-persistent
docker run --name raspap -it -d --restart unless-stopped --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN jrcichra/raspap-docker
docker exec -it raspap bash ./setup.sh

# lan
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# 3g/4g
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE  
iptables -A FORWARD -i eth1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth1 -j ACCEPT

netfilter-persistent save
docker restart raspap
