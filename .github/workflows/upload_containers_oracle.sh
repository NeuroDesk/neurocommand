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
    #build singularity 2 image (as this will also be compatible to 3.x.y)
    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
        echo "${IMAGENAME_BUILDDATE}.simg exists"
    else
        echo "${IMAGENAME_BUILDDATE}.simg does not exist yet - building it!"
        echo "[DEBUG] DOCKERHUB_ORG: $DOCKERHUB_ORG"
        IMAGENAME="$(cut -d'_' -f1,2 <<< ${IMAGENAME_BUILDDATE})"
        BUILDDATE="$(cut -d'_' -f3 <<< ${IMAGENAME_BUILDDATE})"
        echo "[DEBUG] IMAGENAME: $IMAGENAME"
        echo "[DEBUG] BUILDDATE: $BUILDDATE"
        sudo singularity build "$HOME/${IMAGENAME_BUILDDATE}.simg" docker://docker.pkg.github.com/neurodesk/caid/$IMAGENAME:$BUILDDATE

        echo "[DEBUG] Attempting upload to Oracle ..."
        curl -v -X PUT -u ${ORACLE_USER} --upload-file $HOME/${IMAGENAME_BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET
        rm $HOME/${IMAGENAME_BUILDDATE}.simg
        rm -rf /home/runner/.singularity/docker
        df -h

        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
            echo "${IMAGENAME_BUILDDATE}.simg was freshly build and exists now :)"
        else
            echo "${IMAGENAME_BUILDDATE}.simg does not exist yet. Something is WRONG"
            exit 2
        fi
    fi
done < log.txt