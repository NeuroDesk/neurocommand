#!/usr/bin/env bash
# set -e

echo "building cvmfs wishlist"

#creating logfile with available containers
python3 neurodesk/write_log.py

# remove empty lines
sed -i '/^$/d' log.txt

# remove square brackets
sed -i 's/[][]//g' log.txt

# remove spaces around
sed -i -e 's/^[ \t]*//' -e 's/[ \t]*$//' log.txt

# replace spaces with underscores
sed -i 's/ /_/g' log.txt

cp recipe_neurodesk_template.yaml recipe_neurodesk_auto.yaml

while IFS= read -r IMAGENAME_BUILDDATE
do
    IMAGENAME="$(cut -d'_' -f1,2 <<< ${IMAGENAME_BUILDDATE})"
    BUILDDATE="$(cut -d'_' -f3 <<< ${IMAGENAME_BUILDDATE})"
    echo "[DEBUG] IMAGENAME: $IMAGENAME"
    echo "[DEBUG] BUILDDATE: $BUILDDATE"
    echo "- 'https://registry.hub.docker.com/vnmd/$IMAGENAME:$BUILDDATE'" >> recipe_neurodesk_auto.yaml
done < log.txt