#!/bin/zsh

export AWS_REGION=$(aws configure get region)
export ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
export NODE_APP_NAME=node-app-metrics

envsubst < node-app-metrics.yaml
envsubst < node-app-metrics.yaml | kubectl apply -f -

envsubst < node-app-service.yaml
envsubst < node-app-service.yaml | kubectl apply -f -