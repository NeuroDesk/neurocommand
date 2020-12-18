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
        touch ${IMAGENAME_BUILDDATE}.sif
        curl -v -X PUT -u ${ORACLE_USER} --upload-file ${IMAGENAME_BUILDDATE}.sif $ORACLE_NEURODESK_BUCKET   

        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.sif"; then
            echo "${IMAGENAME_BUILDDATE}.sif was freshly uploaded and exists now :)"
        else
            echo "${IMAGENAME_BUILDDATE}.sif does not exist yet"
            exit 2
        fi
    fi
done < log.txt