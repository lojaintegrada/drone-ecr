#!/bin/sh

# support PLUGIN_ and ECR_ variables
[ -n "$ECR_REGION" ] && export PLUGIN_REGION=${ECR_REGION}
[ -n "$ECR_ACCESS_KEY" ] && export PLUGIN_ACCESS_KEY=${ECR_ACCESS_KEY}
[ -n "$ECR_SECRET_KEY" ] && export PLUGIN_SECRET_KEY=${ECR_SECRET_KEY}
[ -n "$ECR_CREATE_REPOSITORY" ] && export PLUGIN_SECRET_KEY=${PLUGIN_CREATE_REPOSITORY}

# set the region
export AWS_DEFAULT_REGION=${PLUGIN_REGION:-'us-east-1'}

if [ -n "$PLUGIN_ACCESS_KEY" ] && [ -n "$PLUGIN_SECRET_KEY" ]; then
  export AWS_ACCESS_KEY_ID=${PLUGIN_ACCESS_KEY}
  export AWS_SECRET_ACCESS_KEY=${PLUGIN_SECRET_KEY}
fi

# get token from aws
aws_auth=$(aws ecr get-authorization-token --output text)

# map some ecr specific variable names to their docker equivalents
export DOCKER_USERNAME=AWS
export DOCKER_PASSWORD=$(echo $aws_auth | cut -d ' ' -f2 | base64 -d | cut -d: -f2)
export DOCKER_REGISTRY=$(echo $aws_auth | cut -d ' ' -f4)

# invoke the docker plugin
/bin/drone-docker "$@"
