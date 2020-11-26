#!/usr/bin/env bash
set -e

echo "[DEBUG] docker run $IMAGEID:$SHORT_SHA ls /neurodesk/"

# docker run $IMAGEID:$SHORT_SHA ls /neurodesk/

# if [ -f /breakhere.sif ]; then
#     echo "Container file exists"
#     exit 0
# else 
#     echo "Container file does not exist!!!!!!!!!"
#     exit 1
# fi