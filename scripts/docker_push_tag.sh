#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 docker_image repository version"
    exit 1
fi

DOCKER_IMAGE=$1
REPOSITORY=$2
TAG=$3

if ! docker images -q | grep $DOCKER_IMAGE > /dev/null; then
    echo "Image($DOCKER_IMAGE) not exists."
    exit 1
fi

docker tag $DOCKER_IMAGE "$REPOSITORY:$TAG"
docker push "$REPOSITORY:$TAG"
