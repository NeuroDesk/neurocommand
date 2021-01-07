#!/usr/bin/env bash
set -e

echo "[DEBUG] Install singularity 2.6.1 from neurodebian"
wget -O- http://neuro.debian.net/lists/bionic.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
# echo "[DEBUG] Install key"
# sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
# keyserver sometimes fails :( -> --allow-unauthenticated as a workaround?
echo "[DEBUG] sudo apt-get update --allow-insecure-repositories"
sudo apt-get update --allow-insecure-repositories
echo "[DEBUG] sudo apt-get update --allow-unauthenticated"
sudo apt-get install --allow-unauthenticated singularity-container 

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


# Oracle Ashburn (with cloud mirror to Zurich) simg
# if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME}_${BUILDDATE}.simg"; then
#     echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg exists in ashburn oracle cloud"
# else

    # check if there is enough free disk space on the runner:
    FREE=`df -k --output=avail "$PWD" | tail -n1`   # df -k not df -h
    echo "[DEBUG] This runner has ${FREE} free disk space"
    if [[ $FREE -lt 10485760 ]]; then               # 10G = 10*1024*1024k
        # less than 10GBs free! clean up!
        bash .github/workflows/free-up-space.sh
    fi;

    sudo singularity build "$IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg" docker://$DOCKERHUB_ORG/${IMAGENAME}:$BUILDDATE

    echo "[DEBUG] Attempting upload to Oracle ..."
    curl -v -X PUT -u ${ORACLE_USER} --upload-file $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg $ORACLE_NEURODESK_BUCKET

    if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/${IMAGENAME}_${BUILDDATE}.simg"; then
        echo "${IMAGENAME}_${BUILDDATE}.simg was freshly build and exists now :)"
    else
        echo "${IMAGENAME}_${BUILDDATE}.simg does not exist yet. Something is WRONG"
        exit 2
    fi
# fi

# Nectar Swift simg
# if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME}_${BUILDDATE}.simg"; then
#     echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg exists in swift storage"
# else
    echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg does not exist yet in nectar swift - building it!"
    if [[ ! -f $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg ]]; then
        sudo singularity build "$IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg" docker://$DOCKERHUB_ORG/$IMAGENAME:$BUILDDATE
    fi

    echo "[DEBUG] Attempting upload to nectar swift ..."
    cd $IMAGE_HOME
    swift upload singularityImages ${IMAGENAME}_${BUILDDATE}.simg --segment-size 1073741824

    if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME}_${BUILDDATE}.simg"; then
        echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg was freshly build and exists now. Cleaning UP! :)"
        rm $IMAGE_HOME/${IMAGENAME}_${BUILDDATE}.simg
        sudo rm -rf /root/.singularity/docker
        df -h
    else
        echo "[DEBUG] ${IMAGENAME}_${BUILDDATE}.simg does not exist yet. Something is WRONG"
        exit 2
    fi
# fi