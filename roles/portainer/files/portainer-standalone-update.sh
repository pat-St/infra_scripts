#!/bin/env bash

set -eo pipefail

NEW_PORTAINER_VERSION=lts
# NEW_PORTAINER_VERSION=lts

jq --version
if [[ ! "$?" -eq 0 ]]; then
	echo "jq not installed"
	exit 1
fi

docker -v
if [[ ! "$?" -eq 0 ]]; then
	echo "docker not installed"
	exit 1
fi

PORTAINER_CONTAINER_EXISTS=$(sudo docker ps --format 'json' | jq -r '.Image | select(contains("portainer"))' | uniq -u | wc -l)

if [[ "$PORTAINER_CONTAINER_EXISTS" -eq 0 ]]; then
	echo "No running portainer found"
	exit 1
fi

PORTAINER_CONTAINER_TYPE=$(sudo docker ps --format 'json' | jq -r '.Image | select(contains("portainer"))' | uniq -u)

if [[ $PORTAINER_CONTAINER_TYPE =~ "agent" ]]; then
	PORTAINER_IMG_NAME="portainer/agent:${NEW_PORTAINER_VERSION}"
	PORTAINER_CONTAINER_NAME="portainer_agent"
	PORTAINER_PORTS="-p 9001:9001"
	PORTAINER_CONTAINER_VOLUME=""
fi
if [[ $PORTAINER_CONTAINER_TYPE =~ "portainer-ce" ]]; then
	PORTAINER_IMG_NAME="portainer/portainer-ce:${NEW_PORTAINER_VERSION}"
	PORTAINER_CONTAINER_NAME="portainer"
	PORTAINER_PORTS="-p 8000:8000 -p 9443:9443"
	PORTAINER_CONTAINER_VOLUME="-v portainer_data:/data"
fi

sudo docker image pull "${PORTAINER_IMG_NAME}"
sudo docker stop "${PORTAINER_CONTAINER_NAME}"
sudo docker rm "${PORTAINER_CONTAINER_NAME}"

sudo docker run -d ${PORTAINER_PORTS} --name=${PORTAINER_CONTAINER_NAME} --restart=always -v /var/run/docker.sock:/var/run/docker.sock ${PORTAINER_CONTAINER_VOLUME} ${PORTAINER_IMG_NAME}
