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

# The aws cli refuses to sign a request without a region. Spaces endpoints carry
# theirs in the hostname, e.g. https://nyc3.digitaloceanspaces.com
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-$(echo "$AWS_S3_ENDPOINT" | sed -E 's#^https?://##; s#\..*##')}

function spaces {
    aws --endpoint-url "$AWS_S3_ENDPOINT" "$@"
}

function set_error_traps {
  # Exit when any command fails
  set -e
}
set_error_traps

# Setup: the aws cli is preinstalled on github runners and reads credentials from the environment
function install {
    if ! command -v aws > /dev/null
    then
        printf "aws cli not found: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html\n"
        exit 1
    fi
    python -m pip install PyYAML
}

function delete {
    shift;
    NAME=$1
    VERSION=$2
    TARGET_PATH=s3://$BUCKET/datasets/$NAME/$VERSION/
    case $VERSION in
        staging|production) printf "\033[0;31mcannot delete $VERSION \n\033[0;31m";;
        *) spaces s3 rm --recursive $TARGET_PATH ;;
    esac
}

function publish {
    shift;
    NAME=$1
    VERSION=${2:-staging}
    STAGING_PATH=s3://$BUCKET/datasets/$NAME/$VERSION/
    echo "$STAGING_PATH"
    PUBLISH_PATH=s3://$BUCKET/datasets/$NAME/production/
    printf "\033[0;31m
        publishing  $STAGING_PATH
        to          $PUBLISH_PATH
    \033[0;31m"
    spaces s3 cp --acl public-read --recursive $STAGING_PATH $PUBLISH_PATH
}

function show {
    shift;
    case $2 in 
        --production|-p) spaces s3 ls --recursive s3://$BUCKET/datasets/$1/production/;;
        --staging|-s) spaces s3 ls --recursive s3://$BUCKET/datasets/$1/staging/;;
        *) spaces s3 ls s3://$BUCKET/datasets/$1/
    esac
}

function list {
    spaces s3api list-objects-v2 --bucket $BUCKET --prefix datasets/ --delimiter / \
        | jq -r '.CommonPrefixes[]?.Prefix | ltrimstr("datasets/") | rtrimstr("/")'
}

# Every object under a prefix as "<key relative to prefix> <etag>", sorted for comm
function etags {
    spaces s3api list-objects-v2 --bucket $BUCKET --prefix "$1" \
        | jq -r --arg prefix "$1" '.Contents[]? | "\(.Key | ltrimstr($prefix)) \(.ETag)"' \
        | sort
}

function diff {
    shift;
    NAME=$1
    VERSION=${2:-staging}
    # A dataset is out of sync when a staging object is missing from production or
    # differs by etag. Extra objects in production don't count.
    if [ -z "$(comm -23 <(etags datasets/$NAME/$VERSION/) <(etags datasets/$NAME/production/))" ]
    then
        status=false
        status_verbose='false'
    else
        status=true
        status_verbose='true'
    fi
}


function different {
    diff $@
    echo $status_verbose
}

function diff_list {
    for key in $(list)
    do
        k=${key%"/"}
        diff "" "$k"
        if $status; 
        then echo "$k"
        fi
    done
}

function convert {
    shift;
    if which python > /dev/null 2>&1;
    then
        python -m convert $1
    else
        python3 -m convert $1
    fi
}

function usage
{
    echo
    echo "Usage:"
    echo "./run.sh [install, show, publish, delete, diff]"
    echo
    echo "Commands:"
    echo "   install:   check for the aws cli and install python dependencies"
    echo "   show:      show available versions and files e.g. ./run.sh show <dataset> --production|--staging"
    echo "   publish:   publish a given dataset from a given candidate version (default candidate is \"staging\")"
    echo "   delete:    deleting a version, by default production and staging cannot be deleted"
    echo "   diff:      detecting if any file difference between production and staging. e.g. ./run.sh diff <dataset>"
    echo "   diff_list: listing all dataset names that are out of sync"
    echo "   list:      listing all dataset names"
    echo "   convert:   convert given .yml file to .json file"
    echo
}

case $1 in
    install) install;;
    show) show $@ ;;
    publish) publish $@ ;;
    delete) delete $@ ;;
    diff) different $@ ;;
    diff_list) diff_list;;
    list) list;;
    convert) convert $@;;
    *) usage;;
esac
