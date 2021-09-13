#!/usr/bin/env bash
set -e
[ -z "$BUILDDATE" ] && BUILDDATE=`date +%Y%m%d`
[ -z "$SHORT_SHA" ] && SHORT_SHA="latest"
docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$1:$BUILDDATE
docker tag $IMAGEID:$SHORT_SHA $DOCKERHUB_ORG/$1:latest
docker push $DOCKERHUB_ORG/$1:latest
docker push $DOCKERHUB_ORG/$1:$BUILDDATE