#!/usr/bin/env bash
# set -e

echo "checking if containers are built"

#creating logfile with available containers
python3 neurodesk/write_log.py

# remove empty lines
sed -i '/^$/d' log.txt

# remove square brackets
sed -i 's/[][]//g' log.txt

# remove spaces around
sed -i -e 's/^[ \t]*//' -e 's/[ \t]*$//' log.txt

# replace spaces with underscores
# sed -i 's/ /_/g' log.txt




echo "$GITHUB_TOKEN" | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
echo "$DOCKERHUB_PASSWORD" | docker login -u $DOCKERHUB_USERNAME --password-stdin

echo "[debug] logfile:"
cat log.txt
echo "[debug] logfile is at: $PWD"


if [ -n "$singularity_setup_done" ]; then
    echo "Setup already done. Skipping."
else
    #setup singularity 2.6.1 from neurodebian
    wget -O- http://neuro.debian.net/lists/focal.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list > /dev/null 2>&1
    echo "[DEBUG] sudo apt-get update --allow-insecure-repositories"
    sudo apt-get update --allow-insecure-repositories > /dev/null 2>&1
    echo "[DEBUG] sudo apt-get update --allow-unauthenticated"
    sudo apt-get install --allow-unauthenticated singularity-container  > /dev/null 2>&1
    sudo apt install singularity-container > /dev/null 2>&1

    export IMAGE_HOME="/home/runner"
    export singularity_setup_done="true"
fi

# another option:
# while IFS="" read -r p || [ -n "$p" ]
# do
#   printf '%s\n' "$p"
# done < peptides.txt
cat log.txt | while read LINE
do
    echo "LINE: $LINE"
    IMAGENAME_BUILDDATE="$(cut -d' ' -f1 <<< ${LINE})"
    echo "IMAGENAME_BUILDDATE: $IMAGENAME_BUILDDATE"

    IMAGENAME="$(cut -d'_' -f1,2 <<< ${IMAGENAME_BUILDDATE})"
    BUILDDATE="$(cut -d'_' -f3 <<< ${IMAGENAME_BUILDDATE})"
    echo "[DEBUG] IMAGENAME: $IMAGENAME"
    echo "[DEBUG] BUILDDATE: $BUILDDATE"

    # Oracle Ashburn (with cloud mirror to Frankfurt)
    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
        echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg exists in ashburn oracle cloud"
    else
        # check if there is enough free disk space on the runner:
        FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
        echo "[DEBUG] This runner has ${FREE} free disk space"
        if [[ $FREE -lt 50485760 ]]; then               # 50G = 10*1024*1024k
            echo "[DEBUG] This runner has not enough free disk space .. cleaning up!"
            bash .github/workflows/free-up-space.sh
            FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
            echo "[DEBUG] This runner has ${FREE} free disk space after cleanup"
        fi;

        echo "[DEBUG] singularity building docker://vnmd/$IMAGENAME:$BUILDDATE"
        singularity build "$IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg"  docker://vnmd/$IMAGENAME:$BUILDDATE

        echo "[DEBUG] Attempting upload to Oracle ..."
        curl -X PUT -u ${ORACLE_USER} --upload-file $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET

        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg was freshly build and exists now :)"
            echo "[DEBUG] PROCEEDING TO NEXT LINE"
        else
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist yet. Something is WRONG"
            exit 2
        fi
    fi 
done

#once everything is uploaded successfully move log file to cvmfs folder, so cvmfs can start downloading the containers:
echo "[Debug] mv logfile to cvmfs directory"
mv log.txt cvmfs
# this file will be committed via uses: stefanzweifel/git-auto-commit-action@v4