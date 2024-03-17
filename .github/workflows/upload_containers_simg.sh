#!/usr/bin/env bash
set -e

echo "checking if containers are built"

#creating logfile with available containers
python3 neurodesk/write_log.py

# remove empty lines
sed -i '/^$/d' log.txt

# remove square brackets
sed -i 's/[][]//g' log.txt

# remove spaces around
sed -i -e 's/^[ \t]*//' -e 's/[ \t]*$//' log.txt

echo "[debug] logfile:"
cat log.txt
echo "[debug] logfile is at: $PWD"

export IMAGE_HOME="/home/runner"

mapfile -t arr < log.txt
for LINE in "${arr[@]}";
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
        # if image is not in Ashburn cloud then check if the image is in the temporary cache:
        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/temporary-builds/${IMAGENAME_BUILDDATE}.simg"; then
            # download simg file from cache:
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg exists in temporary cache on ashburn oracle cloud"
            curl --output "$IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg" "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/temporary-builds/${IMAGENAME_BUILDDATE}.simg"
        else
            # image was not released previously and is not in cache - rebuild from docker:
            # check if there is enough free disk space on the runner:
            FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
            echo "[DEBUG] This runner has ${FREE} free disk space"
            if [[ $FREE -lt 20485760 ]]; then               # 20G = 10*1024*1024k
                echo "[DEBUG] This runner has not enough free disk space .. cleaning up!"
                bash .github/workflows/free-up-space.sh
                FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
                echo "[DEBUG] This runner has ${FREE} free disk space after cleanup"
            fi

            if [ -n "$singularity_setup_done" ]; then
                echo "Setup already done. Skipping."
            else
                #install apptainer
                sudo apt update > /dev/null 2>&1
                sudo apt install -y software-properties-common > /dev/null 2>&1
                sudo add-apt-repository -y ppa:apptainer/ppa > /dev/null 2>&1
                sudo apt update > /dev/null 2>&1
                sudo apt install -y apptainer apptainer-suid > /dev/null 2>&1

                export singularity_setup_done="true"
            fi

            echo "[DEBUG] singularity building docker://vnmd/$IMAGENAME:$BUILDDATE"
            singularity build "$IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg"  docker://vnmd/$IMAGENAME:$BUILDDATE
        fi

        if [ -n "${ORACLE_USER}" ]; then
            echo "[DEBUG] Attempting upload to Oracle ..."
            curl -X PUT -u ${ORACLE_USER} --upload-file $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET

            if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
                echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg was freshly build and exists now :)"
                echo "[DEBUG] PROCEEDING TO NEXT LINE"
                echo "[DEBUG] Cleaning up ..."
                rm -rf /home/runner/.singularity/docker
                rm -rf $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg
            else
                echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist yet. Something is WRONG"
                exit 2
            fi
        else
            echo "Upload credentials not set. NOT uploading. This is OK, if it is an external pull request. Otherwise check credentials."
        fi
    fi 
done < log.txt


if [ -n "${ORACLE_USER}" ]; then
    #once everything is uploaded successfully move log file to cvmfs folder, so cvmfs can start downloading the containers:
    echo "[Debug] mv logfile to cvmfs directory"
    mv log.txt cvmfs

    cd cvmfs
    echo "[Debug] generate applist.json file for website"
    python json_gen.py #this generates the applist.json for the website
    # these files will be committed via uses: stefanzweifel/git-auto-commit-action@v4
else
    echo "Upload credentials not set. NOT saving logfile. This is OK, if it is an external pull request. Otherwise check credentials."
fi
