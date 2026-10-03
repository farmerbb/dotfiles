#!/bin/bash
unset HISTFILE

[[ -f /tmp/adguard-watchdog.running ]] && exit 1
touch /tmp/adguard-watchdog.running

##################################################

detect-abnormal-cpu-usage() {
  CPU_USAGE=$(docker stats --no-stream --format "{{.CPUPerc}}" adguardhome | cut -d'.' -f1)
  [[ -z $CPU_USAGE ]] && return 0
  [[ $CPU_USAGE == 100 ]] && return 0
  [[ $CPU_USAGE > 100 ]] && return 0

  return 1
}

detect-abnormal-cpu-usage && \
  sleep 5 && \
  detect-abnormal-cpu-usage && \
  RESTART_CONTAINER=true

[[ $RESTART_CONTAINER = true ]] && docker restart adguardhome

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/adguard-watchdog.lastrun
rm -f /tmp/adguard-watchdog.running
