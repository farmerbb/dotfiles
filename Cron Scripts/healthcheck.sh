#!/bin/bash
unset HISTFILE

[[ -f /tmp/healthcheck.running ]] && exit 1
touch /tmp/healthcheck.running

##################################################

curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HEALTHCHECK_ID

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/healthcheck.lastrun
rm -f /tmp/healthcheck.running
