#!/bin/bash
unset HISTFILE

[[ -f /tmp/adguard-watchdog.running ]] && exit 1
touch /tmp/adguard-watchdog.running

##################################################

if [[ -z $(which yq) ]]; then
  sudo add-apt-repository -y ppa:rmescandon/yq
  sudo apt-get update
  sudo apt-get install -y yq
fi

KEYS=(
  filtering_enabled
  parental_enabled
  safebrowsing_enabled
  safe_search.enabled
  safe_search.bing
  safe_search.duckduckgo
  safe_search.google
  safe_search.pixabay
  safe_search.yandex
)

for i in "${KEYS[@]}"; do
  if [[ $(yq ".dns.$i" ~/adguardhome/conf/AdGuardHome.yaml) = false ]]; then
    sudo yq -yi ".dns.$i = true" ~/adguardhome/conf/AdGuardHome.yaml
    RESTART_CONTAINER=true
  fi
done

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
