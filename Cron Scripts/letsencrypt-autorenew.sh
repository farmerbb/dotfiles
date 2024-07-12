#!/bin/bash
unset HISTFILE

[[ -f /tmp/letsencrypt-autorenew.running ]] && exit 1
touch /tmp/letsencrypt-autorenew.running

##################################################

mkdir -p ~/Docker/certs
echo 'dns_cloudflare_api_token = [REDACTED]' | sudo tee ~/Docker/certs/cloudflare.ini > /dev/null
sudo chmod 600 ~/Docker/certs/cloudflare.ini

docker run \
  -v /home/farmerbb/Docker/certs:/etc/letsencrypt \
  certbot/dns-cloudflare \
  certonly \
    --non-interactive \
    --dns-cloudflare \
    --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
    --agree-tos \
    -d [REDACTED] \
    -d '*.[REDACTED]' \
    --server https://acme-v02.api.letsencrypt.org/directory

sudo rm ~/Docker/certs/cloudflare.ini

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/letsencrypt-autorenew.lastrun
rm -f /tmp/letsencrypt-autorenew.running
