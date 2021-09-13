#!/usr/bin/env bash
# set -e
echo "$GITHUB_TOKEN" | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
echo "$DOCKERHUB_PASSWORD" | docker login -u $DOCKERHUB_USERNAME --password-stdin