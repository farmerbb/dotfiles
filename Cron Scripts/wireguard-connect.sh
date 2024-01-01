#!/bin/bash
unset HISTFILE

[[ -f /tmp/wireguard-connect.running ]] && exit 1
touch /tmp/wireguard-connect.running

##################################################

timeout 10 nc -z 192.168.86.10 22 2> /dev/null
if [[ $? != 0 ]]; then
  sudo wg-quick down wg0 && sleep 1
  sudo wg-quick up wg0
fi

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/wireguard-connect.lastrun
rm -f /tmp/wireguard-connect.running
