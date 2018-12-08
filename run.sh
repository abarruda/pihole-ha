#!/bin/bash

set -x

touch config/hosts

TEMP_USAGE_DB_PATH=/tmp/pihole-usage-db-vol/
TEMP_USAGE_DB_FILE=pihole-FTL.db

mkdir -p $TEMP_USAGE_DB_PATH
touch $TEMP_USAGE_DB_PATH$TEMP_USAGE_DB_FILE


docker run -d \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 67:67/udp \
    -p 80:80 \
    -p 443:443 \
    -v "$(pwd)/config/pihole/adlists.list:/etc/pihole/adlists.list" \
    -v "$(pwd)/config/pihole/whitelist.txt:/etc/pihole/whitelist.txt" \
    -v "$(pwd)/config/dnsmasq.d/custom-dns.conf:/etc/dnsmasq.d/custom-dns.conf" \
    -e ServerIP="$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')" \
    -e DNS1=8.8.8.8 \
    -e DNS2=208.67.222.222 \
    -e TZ=America/Los_Angeles \
    -e WEBPASSWORD=$PIHOLE_PASS \
    --restart=unless-stopped \
    pihole/pihole:4.0.0-1_armhf
