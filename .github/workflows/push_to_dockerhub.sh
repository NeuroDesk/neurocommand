#!/usr/bin/env bash
set -e
docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$1:$BUILDDATE
docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$1:latest
docker push $DOCKERHUB_ORG/$1:latest
docker push $DOCKERHUB_ORG/$1:$BUILDDATE