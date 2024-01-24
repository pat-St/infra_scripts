#!/bin/env bash
set -eo

docker stop portainer

docker container rm portainer

docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
    -v "/etc/letsencrypt/live/ssl/:/certs:ro" \
    portainer/portainer-ce:latest --sslcert /certs/cert.pem --sslkey /certs/privkey.pem
