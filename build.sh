#!/usr/bin/env bash

set -e

# determine swoole version to build.
TASK=${1}
CHECK=${!#}

function check_or_push() {
    TAG=${1}
    if [[ ${CHECK} == "--check" ]]; then
        echo "Checking $TAG ..."
        version=`docker run hyperf/hyperf:$TAG php -v`
        echo $version | grep -Eo "PHP \d+\.\d+\.\d+"
        swoole=`docker run hyperf/hyperf:$TAG php --ri swoole` && echo $swoole | grep -Eo "Version => \d+\.\d+\.\d+" || echo "No Swoole."
    fi

    if [[ ${CHECK} != "--check" ]]; then
        echo "Publishing "$TAG" ..."
        # Push origin image
        docker push hyperf/hyperf:${TAG}
    fi

    echo -e "\n"
}

# build base image
if [[ ${TASK} == "build" ]]; then
    export PHP_VERSION=7.3 && export ALPINE_VERSION=3.10 && docker-compose build alpine-base
    export PHP_VERSION=7.3 && export ALPINE_VERSION=3.11 && docker-compose build alpine-base

    export PHP_VERSION=7.4 && export ALPINE_VERSION=3.10 && docker-compose build alpine-base
    export PHP_VERSION=7.4 && export ALPINE_VERSION=3.11 && docker-compose build alpine-base
    export PHP_VERSION=7.4 && export ALPINE_VERSION=3.12 && docker-compose build alpine-base

    export PHP_VERSION=8.0 && export ALPINE_VERSION=3.11 && docker-compose build alpine-base
    export PHP_VERSION=8.0 && export ALPINE_VERSION=3.12 && docker-compose build alpine-base
fi

if [[ ${TASK} == "publish" ]]; then
    # Push base image
    TAGS="7.3-alpine-v3.10-base 7.3-alpine-v3.11-base 7.4-alpine-v3.10-base 7.4-alpine-v3.11-base 7.4-alpine-v3.12-base 8.0-alpine-v3.11-base 8.0-alpine-v3.12-base"
    for TAG in ${TAGS}; do
        check_or_push $TAG
    done
fi
