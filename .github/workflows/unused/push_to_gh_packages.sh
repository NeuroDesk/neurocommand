#!/usr/bin/env bash
set -e
docker tag $IMAGEID:$SHORT_SHA $IMAGEID:$BUILDDATE
docker tag $IMAGEID:$SHORT_SHA $IMAGEID:latest
# docker push $IMAGEID:latest
# docker push $IMAGEID:$BUILDDATE