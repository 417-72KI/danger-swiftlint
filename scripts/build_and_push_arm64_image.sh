#!/bin/zsh

if [[ $(arch) != "arm64" ]]; then
    echo "\e[31mThis script must be run on an arm64 machine.\e[m"
    exit 1
fi

local -A opthash
zparseopts -D -A opthash -- -help h -force f

if [[ -n $opthash[(i)--help] ]] || [[ -n $opthash[(i)-h] ]]; then
    echo "Usage: $0 [options] DOCKER_USER IMAGE_NAME"
    echo "Options:"
    echo "  --help  -h: Show this help message"
    echo "  --force -f: Force to build and push images"
    exit 0
fi

if [[ -n $opthash[(i)--force] ]] || [[ -n $opthash[(i)-f] ]]; then
    FORCE=true
else
    FORCE=false
fi

DOCKER_USER=$1
IMAGE_NAME=$2
REPO_ROOT=$(git rev-parse --show-toplevel)

MATRIX_JSON=$(cat "$REPO_ROOT"/.github/matrix.json | jq -rc .)
LATEST_VERSION=$(echo "$MATRIX_JSON" | jq -r '.swift_version[0]')

for version in $(echo "$MATRIX_JSON" | jq -r '.swift_version[]'); do
    # Less than 5.6 doesn't support arm64
    if [[ $(($version)) -lt 5.6 ]]; then
        continue
    fi

    needs_update=$FORCE
    if [[ $FORCE == false ]]; then
        docker manifest rm "$DOCKER_USER/$IMAGE_NAME:$version" > /dev/null 2>/dev/null
        docker manifest inspect "$DOCKER_USER/$IMAGE_NAME:$version" > /dev/null 2>/dev/null
        if [[ $? -ne 0 ]]; then
            needs_update=true
        fi
    fi
    if [[ $needs_update == true ]]; then
        # Pull amd64 image and re-tag
        echo "\e[32mFetching amd64 image for $version started...\e[m"
        docker pull --platform=linux/amd64 "$DOCKER_USER/$IMAGE_NAME:$version"
        echo "\e[32mFetching amd64 image finished!\e[m"
        AMD64_IMAGE_ID=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "$DOCKER_USER/$IMAGE_NAME:$version" | grep -v arm64 | awk '{print $2}')
        docker tag $AMD64_IMAGE_ID "$DOCKER_USER/$IMAGE_NAME:$version-amd64"
        docker push "$DOCKER_USER/$IMAGE_NAME:$version-amd64"
        echo "\e[32mRe-tagging amd64 image for $version finished!\e[m"

        # Build arm64 image
        echo "\e[32mBuilding arm64 image for $version started...\e[m"
        swiftlint_version=$(echo "$MATRIX_JSON" | jq -r ".swiftlint_supported_version[\"$version\"]")
        docker build --build-arg SWIFT_VERSION=$version --build-arg SWIFT_LINT_REVISION=$swiftlint_version -t "$DOCKER_USER/$IMAGE_NAME:$version-arm64" -f "$REPO_ROOT/Dockerfile" "$REPO_ROOT"
        if [[ $? -eq 0 ]]; then
            docker push "$DOCKER_USER/$IMAGE_NAME:$version-arm64"
            echo "\e[32mBuilding arm64 image finished!\e[m"

            # Create manifest
            echo "\e[32mCreating manifest started...\e[m"
            docker manifest create "$DOCKER_USER/$IMAGE_NAME:$version" \
                --amend "$DOCKER_USER/$IMAGE_NAME:$version-amd64" \
                --amend "$DOCKER_USER/$IMAGE_NAME:$version-arm64"
            docker manifest push "$DOCKER_USER/$IMAGE_NAME:$version"
            echo "\e[32mCreating manifest finished!\e[m"

            # Create latest manifest
            if [[ "$version" == "$LATEST_VERSION" ]]; then
                echo "\e[32mCreating latest manifest...\e[m"
                docker manifest create "$DOCKER_USER/${IMAGE_NAME}:latest" \
                    --amend "$DOCKER_USER/$IMAGE_NAME:$version-amd64" \
                    --amend "$DOCKER_USER/$IMAGE_NAME:$version-arm64"
                docker manifest push "$DOCKER_USER/${IMAGE_NAME}:latest"
            fi
        else
            echo "\e[31mBuilding arm64 image for $version failed!\e[m"
        fi

        # Clean up
        docker image rm "$DOCKER_USER/$IMAGE_NAME:$version" \
            "$DOCKER_USER/$IMAGE_NAME:$version-amd64" \
            "$DOCKER_USER/$IMAGE_NAME:$version-arm64"

        # Clean up on Docker Hub
        DOCKER_HUB_TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d "{\"username\": \"$DOCKER_USER\",\"password\": \"$DOCKER_HUB_PASSWORD\"}" "https://hub.docker.com/v2/users/login/" | jq -r .token`
        curl -sS "https://hub.docker.com/v2/repositories/${DOCKER_USER}/${IMAGE_NAME}/tags/${version}-amd64/" \
            -X DELETE \
            -H "Authorization: JWT ${DOCKER_HUB_TOKEN}"
        curl -sS "https://hub.docker.com/v2/repositories/${DOCKER_USER}/${IMAGE_NAME}/tags/${version}-arm64/" \
            -X DELETE \
            -H "Authorization: JWT ${DOCKER_HUB_TOKEN}"
    else
        echo "\e[32mSkipping for $version...\e[m"
    fi
done
