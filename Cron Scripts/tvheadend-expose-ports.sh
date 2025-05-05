#!/bin/bash
unset HISTFILE

[[ -f /tmp/tvheadend-expose-ports.running ]] && exit 1
touch /tmp/tvheadend-expose-ports.running

##################################################

for i in 9981 9982; do
  sudo iptables -t nat -I PREROUTING -p tcp --dport $i -j DNAT --to-destination=10.13.13.4:$i
done

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/tvheadend-expose-ports.lastrun
rm -f /tmp/tvheadend-expose-ports.running
