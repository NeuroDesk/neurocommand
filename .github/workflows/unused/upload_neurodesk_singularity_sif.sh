#!/usr/bin/env bash
set -e

echo "[DEBUG] Configure for SWIFT storage"
sudo pip install wheel
sudo pip install python-swiftclient python-keystoneclient
export OS_AUTH_URL=https://keystone.rc.nectar.org.au:5000/v3/
export OS_AUTH_TYPE=v3applicationcredential
export OS_PROJECT_NAME="CAI_Container_Builder"
export OS_USER_DOMAIN_NAME="Default"
export OS_REGION_NAME="Melbourne"

export BUILDDATE=`date +%Y%m%d`
export IMAGENAME="neurodesk"
export IMAGE_HOME="/home/runner"



echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.sif does not exist yet in nectar swift - building it!"
if [[ ! -f $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.sif ]]; then
    REGISTRY=$(echo docker.pkg.github.com/$GITHUB_REPOSITORY | tr '[A-Z]' '[a-z]')
    echo "[DEBUG] REGISTRY: $REGISTRY"
    echo "[DEBUG] IMAGENAME: $IMAGENAME"
    IMAGEID="$DOCKERHUB_ORG/$IMAGENAME"
    echo "[DEBUG] IMAGEID: $IMAGEID"

    echo "[DEBUG] Pulling latest build of singularity ..."
    docker pull $REGISTRY/singularity3
    echo "[DEBUG] Build singularity sif container ..."
    echo "[DEBUG] docker run -v $IMAGE_HOME:/home $REGISTRY/singularity3 build /home/${IMAGENAME}_${BUILDDATE}.sif docker://$DOCKERHUB_ORG/$IMAGENAME"
    docker run -v $IMAGE_HOME:/home $REGISTRY/singularity3 build "/home/${IMAGENAME}_${BUILDDATE}.sif" docker://$DOCKERHUB_ORG/$IMAGENAME
fi

echo "[DEBUG] Attempting upload to Oracle ..."
curl -v -X PUT -u ${ORACLE_USER} --upload-file $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.sif $ORACLE_NEURODESK_BUCKET

if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME}_${BUILDDATE}.sif"; then
    echo "${IMAGENAME}_${BUILDDATE}.sif was freshly build and exists now :)"
else
    echo "${IMAGENAME}_${BUILDDATE}.sif does not exist yet. Something is WRONG"
    exit 2
fi

echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.sif does not exist yet in nectar swift - building it!"
if [[ ! -f $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.sif ]]; then
    REGISTRY=$(echo docker.pkg.github.com/$GITHUB_REPOSITORY | tr '[A-Z]' '[a-z]')
    echo "[DEBUG] REGISTRY: $REGISTRY"
    echo "[DEBUG] IMAGENAME: $IMAGENAME"
    IMAGEID="$DOCKERHUB_ORG/$IMAGENAME"
    echo "[DEBUG] IMAGEID: $IMAGEID"

    echo "[DEBUG] Pulling latest build of singularity ..."
    docker pull $REGISTRY/singularity3
    echo "[DEBUG] Build singularity sif container ..."
    echo "[DEBUG] docker run -v $IMAGE_HOME:/home $REGISTRY/singularity3 build /home/${IMAGENAME}_${BUILDDATE}.sif docker://$DOCKERHUB_ORG/$IMAGENAME"
    docker run -v $IMAGE_HOME:/home $REGISTRY/singularity3 build "/home/${IMAGENAME}_${BUILDDATE}.sif" docker://$DOCKERHUB_ORG/$IMAGENAME
fi

echo "[DEBUG] Attempting upload to nectar swift ..."
cd $IMAGE_HOME
swift upload singularityImages ${IMAGENAME}_${BUILDDATE}.sif --segment-size 1073741824

if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME}_${BUILDDATE}.sif"; then
    echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.sif was freshly build and exists now. Cleaning UP! :)"
    rm $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.sif
    sudo rm -rf /root/.singularity/docker
    df -h
else
    echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.sif does not exist yet. Something is WRONG"
    exit 2
fi
