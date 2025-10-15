#!/bin/bash
unset HISTFILE

[[ -f /tmp/nuc-iptables.running ]] && exit 1
touch /tmp/nuc-iptables.running

##################################################

# Tvheadend
for i in 9981 9982; do
  sudo iptables -t nat -I PREROUTING -p tcp --dport $i -j DNAT --to-destination=10.13.13.4:$i
done

# LAN access via WireGuard
sudo iptables -A FORWARD -i wg0 -o eno1 -j ACCEPT
sudo iptables -A FORWARD -i eno1 -o wg0 -j ACCEPT

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/nuc-iptables.lastrun
rm -f /tmp/nuc-iptables.running
