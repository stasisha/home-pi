#!/bin/bash

# lan
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# 3g/4g
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE  
iptables -A FORWARD -i eth1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth1 -j ACCEPT
