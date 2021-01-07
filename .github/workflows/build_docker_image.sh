#!/usr/bin/env bash
set -e
SHORT_SHA=$(git rev-parse --short $GITHUB_SHA)
docker build . --file $1/Dockerfile --tag $IMAGEID:$SHORT_SHA --cache-from $IMAGEID --label "GITHUB_REPOSITORY=$GITHUB_REPOSITORY" --label "GITHUB_SHA=$GITHUB_SHA"
ROOTFS_NEW=$(docker inspect --format='{{.RootFS}}' $IMAGEID:$SHORT_SHA)
BUILDDATE=`date +%Y%m%d`
echo "SHORT_SHA=$SHORT_SHA" >> $GITHUB_ENV
echo "ROOTFS_NEW=$ROOTFS_NEW" >> $GITHUB_ENV
echo "BUILDDATE=$BUILDDATE" >> $GITHUB_ENV