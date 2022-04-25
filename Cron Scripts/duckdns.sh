#!/bin/bash
unset HISTFILE

[[ -f /tmp/duckdns.running ]] && exit 1
touch /tmp/duckdns.running

##################################################

echo url="https://www.duckdns.org/update?domains=farmerbb&token=[REDACTED]&ip=" | curl -k -o /dev/null -K -

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/duckdns.lastrun
rm -f /tmp/duckdns.running
