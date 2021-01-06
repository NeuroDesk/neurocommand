#!/usr/bin/env bash
# set -e
echo "${{ secrets.GITHUB_TOKEN }}" | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
echo "${{ secrets.DOCKERHUB_PASSWORD }}" | docker login -u ${{ secrets.DOCKERHUB_USERNAME }} --password-stdin