#!/usr/bin/env bash
# set -e
export IMAGENAME="neurodesk"
export OS_AUTH_URL=https://keystone.rc.nectar.org.au:5000/v3/
export OS_AUTH_TYPE=v3applicationcredential
export OS_PROJECT_NAME="CAI_Container_Builder"
export OS_USER_DOMAIN_NAME="Default"
export OS_REGION_NAME="Melbourne"

# Oracle Ashburn (with cloud mirror to Zurich)
if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME}_${BUILDDATE}.simg"; then
    echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg exists in ashburn oracle cloud"
else

    sudo singularity build "$IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg" docker://$DOCKERHUB_ORG/${IMAGENAME}:$BUILDDATE

    echo "[DEBUG] Attempting upload to Oracle ..."
    curl -v -X PUT -u ${ORACLE_USER} --upload-file $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET

    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME}_${BUILDDATE}.simg"; then
        echo "${IMAGENAME}_${BUILDDATE}.simg was freshly build and exists now :)"
    else
        echo "${IMAGENAME}_${BUILDDATE}.simg does not exist yet. Something is WRONG"
        exit 2
    fi
fi

# Nectar Swift
if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME}_${BUILDDATE}.simg"; then
    echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg exists in swift storage"
else
    echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg does not exist yet in nectar swift - building it!"
    if [[ ! -f $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg ]]; then
        sudo singularity build "$IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg" docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE
    fi

    echo "[DEBUG] Attempting upload to nectar swift ..."
    swift upload singularityImages $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg --segment-size 1073741824

    if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME}_${BUILDDATE}.simg"; then
        echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg was freshly build and exists now. Cleaning UP! :)"
        rm $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg
        sudo rm -rf /root/.singularity/docker
        df -h
    else
        echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg does not exist yet. Something is WRONG"
        exit 2
    fi
fi