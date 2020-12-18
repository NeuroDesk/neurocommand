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

#setup singularity 2.6.1 from neurodebian
wget -O- http://neuro.debian.net/lists/bionic.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
sudo apt-get update
sudo apt-get install singularity-container

while IFS= read -r IMAGENAME_BUILDDATE
do
  echo "$IMAGENAME_BUILDDATE"
    #build singularity 3 image
    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.sif"; then
        echo "${IMAGENAME_BUILDDATE}.sif exists"
    else
        echo "${IMAGENAME_BUILDDATE}.sif does not exist yet - building it!"
        
        echo "[DEBUG] DOCKERHUB_ORG: $DOCKERHUB_ORG"
        REGISTRY=$(echo docker.pkg.github.com/$GITHUB_REPOSITORY | tr '[A-Z]' '[a-z]')
        echo "[DEBUG] REGISTRY: $REGISTRY"
        IMAGEID="$DOCKERHUB_ORG/$IMAGENAME_BUILDDATE"
        echo "[DEBUG] IMAGEID: $IMAGEID"
        IMAGENAME="$(cut -d'_' -f1,2 <<< ${IMAGENAME_BUILDDATE})"
        BUILDDATE="$(cut -d'_' -f3 <<< ${IMAGENAME_BUILDDATE})"
        echo "[DEBUG] IMAGENAME: $IMAGENAME"
        echo "[DEBUG] BUILDDATE: $BUILDDATE"

        echo "[DEBUG] Pulling latest build of singularity ..."
        docker pull $REGISTRY/singularity3
        echo "[DEBUG] Build singularity container ..."
        echo "[DEBUG] docker run -v $HOME:/home $REGISTRY/singularity build /home/${IMAGENAME_BUILDDATE}.sif docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE"
        docker run -v $HOME:/home $REGISTRY/singularity3 build "/home/${IMAGENAME_BUILDDATE}.sif" docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE

        echo "[DEBUG] Attempting upload to Oracle ..."
        curl -v -X PUT -u ${ORACLE_USER} --upload-file $HOME/${IMAGENAME_BUILDDATE}.sif $ORACLE_NEURODESK_BUCKET
        rm $HOME/${IMAGENAME_BUILDDATE}.sif
        df -h

        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.sif"; then
            echo "${IMAGENAME_BUILDDATE}.sif was freshly build and exists now :)"
        else
            echo "${IMAGENAME_BUILDDATE}.sif does not exist yet. Something is WRONG"
            exit 2
        fi
    fi

    #build singularity 2 image
    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
        echo "${IMAGENAME_BUILDDATE}.simg exists"
    else
        echo "${IMAGENAME_BUILDDATE}.simg does not exist yet - building it!"
        singularity build "/home/${IMAGENAME_BUILDDATE}.simg" docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE

        echo "[DEBUG] Attempting upload to Oracle ..."
        curl -v -X PUT -u ${ORACLE_USER} --upload-file $HOME/${IMAGENAME_BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET
        rm $HOME/${IMAGENAME_BUILDDATE}.simg
        df -h

        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
            echo "${IMAGENAME_BUILDDATE}.simg was freshly build and exists now :)"
        else
            echo "${IMAGENAME_BUILDDATE}.simg does not exist yet. Something is WRONG"
            exit 2
        fi
    fi
done < log.txt