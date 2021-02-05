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
function install {
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
        *) mc ls spaces/$BUCKET/datasets/$1/
    esac
}

function compare {
    shift;
    FILE=$1
    NAME=`echo "$FILE" | cut -d'.' -f1`
    STAGING=$(mc stat spaces/edm-publishing/datasets/$NAME/staging/$FILE --json | jq -r '.[] | .ETag')
    PROD=$(mc stat spaces/edm-publishing/datasets/$NAME/production/$FILE --json | jq -r '.[] | .ETag')
    if [ $STAGING == $PROD ]
    then
        # Files are the same, no action needed
        return 0 
    else
        # Files are different, needs review
        return 0
    fi
}

function usage()
{
    echo
    echo "Usage:"
    echo "./run.sh [install, show, publish, delete]"
    echo
    echo "Commands:"
    echo "   install:   Install minio and configure host -- spaces"
    echo "   show:      show available versions and files e.g. ./run.sh show <dataset> --production|--staging"
    echo "   publish:   publish a given dataset from a given candidate version (default candidate is \"staging\")"
    echo "   delete:    deleting a version, by default production and staging cannot be deleted"
    echo
}

case $1 in
    install) install;;
    show) show $@ ;;
    publish) publish $@ ;;
    delete) delete $@ ;;
    *) usage;;
esac