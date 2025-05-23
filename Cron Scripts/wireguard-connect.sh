#!/bin/bash
unset HISTFILE

[[ -f /run/user/$UID/.wireguard-connect ]] && exit 1
touch /run/user/$UID/.wireguard-connect

##################################################

handle-wireguard() {
  PUBLIC_IP=$(timeout 10 dig @resolver4.opendns.com myip.opendns.com +short)

  timeout 10 nc -z 192.168.86.10 22 2> /dev/null
  if [[ $? != 0 ]]; then
    sudo wg-quick down wg0 && sleep 1
    [[ -z $PUBLIC_IP ]] && return 0
    [[ $PUBLIC_IP == [REDACTED] ]] && return 0
    rm -f /tmp/.wg-force-up
    sudo wg-quick up wg0
  elif [[ -f /tmp/.wg-force-up ]]; then
    return 0
  else
    [[ $PUBLIC_IP == [REDACTED] ]] && sudo wg-quick down wg0
    return 0
  fi
}

handle-wireguard

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/wireguard-connect.lastrun
rm -f /run/user/$UID/.wireguard-connect
