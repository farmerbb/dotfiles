#!/bin/bash
unset HISTFILE

[[ -f /tmp/letsencrypt-autorenew.running ]] && exit 1
touch /tmp/letsencrypt-autorenew.running

##################################################

if [[ -z $(which certbot) ]]; then
  sudo apt-get update
  sudo apt-get install -y python3-certbot-dns-cloudflare
fi

CERT_DIR=/etc/letsencrypt
CREDS=$CERT_DIR/cloudflare.ini

sudo mkdir -p $CERT_DIR
echo 'dns_cloudflare_api_token = [REDACTED]' | sudo tee $CREDS > /dev/null
sudo chmod 600 $CREDS

sudo certbot certonly \
  --non-interactive \
  --dns-cloudflare \
  --dns-cloudflare-credentials $CREDS \
  --agree-tos \
  --email [REDACTED] \
  -d [REDACTED] \
  -d '*.[REDACTED]' \
  --server https://acme-v02.api.letsencrypt.org/directory

sudo rm $CREDS

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/letsencrypt-autorenew.lastrun
rm -f /tmp/letsencrypt-autorenew.running
