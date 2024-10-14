edit-docker-compose-yml() {
  FILE=~/Docker/docker-compose.yml
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano "$FILE"
    if [[ $(md5sum "$FILE") != $MD5 ]]; then
      docker compose -f "$FILE" up -d --remove-orphans

      for i in OneDrive/Other\ Stuff/Docker Other\ Stuff/Docker; do
        cp "$FILE" "/home/farmerbb/$i/docker-compose.yml"
      done
    fi
  fi
}

plex-backup() {
  echo "Temporarily stopping Plex server..."
  docker stop plex

  PLEX_DIR="/home/farmerbb/Docker/plex/config"
  BACKUP_DIR="/mnt/files/Local/plex-backup"
  mkdir -p "$BACKUP_DIR"

  sudo rsync -avu --delete --inplace "$PLEX_DIR/" "$BACKUP_DIR"

  docker start plex
}

plex-restore() {
  echo "Temporarily stopping Plex server..."
  docker stop plex

  PLEX_DIR="/home/farmerbb/Docker/plex/config"
  BACKUP_DIR="/mnt/files/Local/plex-backup"
  mkdir -p "$BACKUP_DIR"

  sudo rsync -avu --delete --inplace "$BACKUP_DIR/" "$PLEX_DIR"

  docker start plex
}

home-assistant-restore() {
  docker stop homeassistant

  cd ~/Docker
  mv homeassistant homeassistant-old
  mkdir homeassistant

  tar -xOf ~/Other\ Stuff/Docker/homeassistant-*.tar "homeassistant.tar.gz" | tar --strip-components=1 -zxf - -C homeassistant

  docker start homeassistant
  rm -rf homeassistant-old

  cd - >/dev/null
}

export -f plex-backup
export -f plex-restore
export -f home-assistant-restore
