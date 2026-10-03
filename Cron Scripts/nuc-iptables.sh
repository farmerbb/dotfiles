#!/bin/bash
unset HISTFILE

[[ -f /tmp/nuc-iptables.running ]] && exit 1
touch /tmp/nuc-iptables.running

##################################################

# Tvheadend HTSP
sudo iptables -t nat -A PREROUTING -p tcp -d 192.168.86.10 --dport 9982 -j DNAT --to-destination 10.13.13.4:9982
sudo iptables -A FORWARD -p tcp -d 10.13.13.4 --dport 9982 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o wg0 -p tcp -d 10.13.13.4 --dport 9982 -j MASQUERADE

# LAN access via WireGuard
sudo iptables -A FORWARD -i wg0 -o eno1 -j ACCEPT
sudo iptables -A FORWARD -i eno1 -o wg0 -j ACCEPT

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/nuc-iptables.lastrun
rm -f /tmp/nuc-iptables.running
