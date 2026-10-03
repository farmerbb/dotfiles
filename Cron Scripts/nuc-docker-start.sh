#!/bin/bash
unset HISTFILE

[[ -f /tmp/nuc-docker-start.running ]] && exit 1
touch /tmp/nuc-docker-start.running

##################################################

docker compose -f ~/Docker/docker-compose.yml up -d --remove-orphans

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/nuc-docker-start.lastrun
rm -f /tmp/nuc-docker-start.running
