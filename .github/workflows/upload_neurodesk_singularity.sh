#!/usr/bin/env bash
# set -e
    export IMAGENAME="neurodesk"
    export BUILDDATE="latest"
    # Oracle Ashburn (with cloud mirror to Zurich)
    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME}_${BUILDDATE}.simg"; then
        echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg exists in ashburn oracle cloud"
    else

        sudo singularity build "$IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg" docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE

        echo "[DEBUG] Attempting upload to Oracle ..."
        curl -v -X PUT -u ${ORACLE_USER} --upload-file $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET

        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
            echo "${IMAGENAME_BUILDDATE}.simg was freshly build and exists now :)"
        else
            echo "${IMAGENAME_BUILDDATE}.simg does not exist yet. Something is WRONG"
            exit 2
        fi
    fi

    # Nectar Swift
    if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME_BUILDDATE}.simg"; then
        echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg exists in swift storage"
    else
        echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist yet in nectar swift - building it!"
        if [[ ! -f $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg ]]; then
            sudo singularity build "$IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg" docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE
        fi

        echo "[DEBUG] Attempting upload to nectar swift ..."
        swift upload singularityImages $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg --segment-size 1073741824

        if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME_BUILDDATE}.simg"; then
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg was freshly build and exists now. Cleaning UP! :)"
            rm $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg
            sudo rm -rf /root/.singularity/docker
            df -h
        else
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist yet. Something is WRONG"
            exit 2
        fi
    fi