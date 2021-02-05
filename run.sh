#!/bin/bash

# Set Environmental Variables
function set_env {
  for envfile in $@
  do
    if [ -f $envfile ]
      then
        export $(cat $envfile | sed 's/#.*//g' | xargs)
      fi
  done
}
set_env .env
BUCKET=$AWS_S3_BUCKET

# Setup: Download and Install minio
function Setup {
    curl -O https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2020-10-03T02-54-56Z
    mv mc.RELEASE.2020-10-03T02-54-56Z mc
    chmod +x mc
    sudo mv ./mc /usr/bin
    mc config host add spaces $AWS_S3_ENDPOINT $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY --api S3v4
}

function delete {
    shift;
    NAME=$1
    VERSION=$2
    TARGET_PATH=spaces/$BUCKET/datasets/$1/$VERSION/
    case $VERSION in
        staging|production) printf "\033[0;31mcannot delete $VERSION \n\033[0;31m";;
        *) mc rm --recursive --force $TARGET_PATH ;;
    esac
}

function publish {
    shift;
    NAME=$1
    VERSION=${2:-staging}
    STAGING_PATH=spaces/$BUCKET/datasets/$1/$VERSION/
    PUBLISH_PATH=spaces/$BUCKET/datasets/$1/production/
    printf "\033[0;31m
        publishing  $STAGING_PATH
        to          $PUBLISH_PATH
    \033[0;31m"
    mc cp --recursive $STAGING_PATH $PUBLISH_PATH
}

function show {
    shift;
    case $2 in 
        --production|-p) mc ls --recursive spaces/$BUCKET/datasets/$1/production;;
        --staging|-s) mc ls --recursive spaces/$BUCKET/datasets/$1/staging;;
        *) printf "\033[0;31mplease specify flag --production (-p) or --staging (-s)\n\033[0;31m"
    esac
}

case $1 in
    show) show $@ ;;
    publish) publish $@ ;;
    delete) delete $@ ;;
    *) echo "unknow command $1";;
esac