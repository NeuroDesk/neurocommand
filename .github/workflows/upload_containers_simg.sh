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
sed -i 's/ /_/g' log.txt

echo "$GITHUB_TOKEN" | docker login docker.pkg.github.com -u $GITHUB_ACTOR --password-stdin
echo "$DOCKERHUB_PASSWORD" | docker login -u $DOCKERHUB_USERNAME --password-stdin

while IFS= read -r IMAGENAME_BUILDDATE
do
    IMAGENAME="$(cut -d'_' -f1,2 <<< ${IMAGENAME_BUILDDATE})"
    BUILDDATE="$(cut -d'_' -f3 <<< ${IMAGENAME_BUILDDATE})"
    echo "[DEBUG] IMAGENAME: $IMAGENAME"
    echo "[DEBUG] BUILDDATE: $BUILDDATE"

    # Oracle Ashburn (with cloud mirror to Zurich)
    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
        echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg exists in ashburn oracle cloud"
    else
        # check if there is enough free disk space on the runner:
        FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
        echo "[DEBUG] This runner has ${FREE} free disk space"
        if [[ $FREE -lt 30485760 ]]; then               # 30G = 10*1024*1024k
            echo "[DEBUG] This runner has not enough free disk space .. cleaning up!"
            bash .github/workflows/free-up-space.sh
        fi;

        if [ -n "$singularity_setup_done" ]; then
            echo "Setup already done. Skipping."
        else
            #setup singularity 2.6.1 from neurodebian
            wget -O- http://neuro.debian.net/lists/bionic.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
            sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
            sudo apt-get update
            sudo apt-get install singularity-container

            export IMAGE_HOME="/home/runner"
            export singularity_setup_done="true"
        fi

        echo "[DEBUG] singularity building docker://vnmd/$IMAGENAME:$BUILDDATE"
        sudo singularity build "$IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg"  docker://vnmd/$IMAGENAME:$BUILDDATE

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
        echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist yet in nectar swift - uploading it there as well!"
        # check if there is enough free disk space on the runner:
        FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
        echo "[DEBUG] This runner has ${FREE} free disk space"
        if [[ $FREE -lt 10485760 ]]; then               # 10G = 10*1024*1024k
            echo "[DEBUG] This runner has not enough free disk space .. cleaning up!"
            bash .github/workflows/free-up-space.sh
        fi;

        if [ -n "$swift_setup_done" ]; then
            echo "Setup already done. Skipping."
        else
            echo "[DEBUG] Configure for SWIFT storage"
            sudo pip3 install setuptools
            sudo pip3 install wheel
            sudo pip3 install python-swiftclient python-keystoneclient
            export OS_AUTH_URL=https://keystone.rc.nectar.org.au:5000/v3/
            export OS_AUTH_TYPE=v3applicationcredential
            export OS_PROJECT_NAME="CAI_Container_Builder"
            export OS_USER_DOMAIN_NAME="Default"
            export OS_REGION_NAME="Melbourne"

            export IMAGE_HOME="/home/runner"
            export swift_setup_done="true"
        fi


        echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist locally - pulling it from oracle cloud!"
        if [[ ! -f $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg ]]; then
            curl -X GET https://objectstorage.eu-zurich-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg -o $IMAGE_HOME/${IMAGENAME_BUILDDATE}.simg
        fi

        echo "[DEBUG] Attempting upload to nectar swift ..."
        cd $IMAGE_HOME
        swift upload singularityImages ${IMAGENAME_BUILDDATE}.simg --segment-size 1073741824

        if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME_BUILDDATE}.simg"; then
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg was freshly build and exists now. Cleaning UP! :)"
            rm ${IMAGENAME_BUILDDATE}.simg
            sudo rm -rf /root/.singularity/docker
            df -h
        else
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist yet. Something is WRONG"
            exit 2
        fi
    fi
done < log.txt