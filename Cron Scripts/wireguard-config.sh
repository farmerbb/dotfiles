#!/bin/bash
unset HISTFILE

[[ -f /run/user/$UID/.wireguard-config ]] && exit 1
touch /run/user/$UID/.wireguard-config

##################################################

PEER_PUBKEY="[REDACTED]"
PUBLIC_IP=$(timeout 10 dig @resolver4.opendns.com myip.opendns.com +short)

if [[ "$PUBLIC_IP" == [REDACTED] ]]; then
  # At home
  sudo wg set wg0 peer "$PEER_PUBKEY" allowed-ips 192.168.86.10/32,10.13.13.0/24
  sudo ip route replace 192.168.86.10/32 dev wg0
  sudo ip route del 192.168.86.0/24 dev wg0
else
  # Away from home
  sudo wg set wg0 peer "$PEER_PUBKEY" allowed-ips 192.168.86.0/24,10.13.13.0/24
  sudo ip route replace 192.168.86.0/24 dev wg0
  sudo ip route del 192.168.86.10/32 dev wg0
fi

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/wireguard-config.lastrun
rm -f /run/user/$UID/.wireguard-config
