#!/usr/bin/env bash
# set -e

echo "checking if containers are built"

#creating logfile with available containers
cd neurodesk
python write_log.py

# remove empty lines
sed -i '/^$/d' log.txt

# remove square brackets
sed -i 's/[][]//g' log.txt

# remove spaces around
sed -i -e 's/^[ \t]*//' -e 's/[ \t]*$//' log.txt

# replace spaces with underscores
sed -i 's/ /_/g' log.txt


while IFS= read -r IMAGENAME_BUILDDATE
do
  echo "$IMAGENAME_BUILDDATE"
    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.sif"; then
        echo "${IMAGENAME_BUILDDATE}.sif exists"
    else
        echo "${IMAGENAME_BUILDDATE}.sif does not exist yet - building it!"
        
        echo "[DEBUG] DOCKERHUB_ORG: $DOCKERHUB_ORG"
        REGISTRY=$(echo docker.pkg.github.com/$GITHUB_REPOSITORY | tr '[A-Z]' '[a-z]')
        echo "[DEBUG] REGISTRY: $REGISTRY"
        IMAGEID="$DOCKERHUB_ORG/$IMAGENAME_BUILDDATE"
        echo "[DEBUG] IMAGEID: $IMAGEID"

        echo "[DEBUG] Pulling latest build of singularity ..."
        docker pull $REGISTRY/singularity3
        echo "[DEBUG] Build singularity container ..."
        echo "[DEBUG] docker run -v $HOME:/home $REGISTRY/singularity build /home/${IMAGENAME_BUILDDATE}.sif docker://$DOCKERHUB_ORG/$IMAGENAME"
        docker run -v $HOME:/home $REGISTRY/singularity3 build "/home/${IMAGENAME_BUILDDATE}.sif" docker://$DOCKERHUB_ORG/$IMAGENAME

        echo "[DEBUG] Attempting upload to Oracle ..."
        curl -v -X PUT -u ${ORACLE_USER} --upload-file ${IMAGENAME_BUILDDATE}.sif $ORACLE_NEURODESK_BUCKET   

        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.sif"; then
            echo "${IMAGENAME_BUILDDATE}.sif was freshly build and exists now :)"
        else
            echo "${IMAGENAME_BUILDDATE}.sif does not exist yet. Something is WRONG"
            exit 2
        fi
    fi
done < log.txt