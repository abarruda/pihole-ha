#!/bin/bash

set -x

docker run -d \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 67:67/udp \
    -p 80:80 \
    -p 443:443 \
    -v "$(pwd)/data/pihole:/etc/pihole" \
    -v "$(pwd)/data/dnsmasq.d/custom-dns.conf:/etc/dnsmasq.d/custom-dns.conf" \
    -e ServerIP="$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')" \
    -e DNS1=8.8.8.8 \
    -e DNS2=208.67.222.222 \
    -e TZ=America/Los_Angeles \
    -e WEBPASSWORD=$PIHOLE_PASS \
    --restart=unless-stopped \
    pihole/pihole:4.0.0-1_armhf
