#!/bin/bash
if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAMENAME}_${BUILDDATE}.sif"; then
    echo "${IMAGENAME}_${BUILDDATE}.sif exists"
    exit 0
else
    echo "${IMAGENAME}_${BUILDDATE}.sif does not exist yet"
    exit 2
fi