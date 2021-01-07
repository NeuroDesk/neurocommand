#!/usr/bin/env bash
# set -e
        IMAGEID=docker.pkg.github.com/$GITHUB_REPOSITORY/$1
        IMAGEID=$(echo $IMAGEID | tr '[A-Z]' '[a-z]')
        {
          docker pull $IMAGEID \
            && ROOTFS_CACHE=$(docker inspect --format='{{.RootFS}}' $IMAGEID) \
            && echo "ROOTFS_CACHE=$ROOTFS_CACHE" >> $GITHUB_ENV
        } || echo "[DEBUG] $IMAGEID not found. Resuming build..."
        echo "IMAGEID=$IMAGEID" >> $GITHUB_ENV