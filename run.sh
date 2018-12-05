#!/bin/bash

docker run -d \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 67:67/udp \
    -p 80:80 \
    -p 443:443 \
    -v "config/pihole/:/etc/pihole/" \
    -v "config/dnsmasq.d/:/etc/dnsmasq.d/" \
    -v "config/hosts:/etc/hosts" \
    -e ServerIP="$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')" \
    --restart=unless-stopped \
    --dns=8.8.8.8 --dns=208.67.222.222 \
    pihole/pihole:4.0.0-1_armhf