#!/usr/bin/env bash
# set -e

#setup singularity 2.6.1 from neurodebian
wget -O- http://neuro.debian.net/lists/bionic.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
sudo apt-get update
sudo apt-get install singularity-container 

echo "checking if neurodesk installs and a containers gets downloaded correctly"

echo "python version is ... "
python --version
echo "singularity version is ... "
singularity --version
echo "where am I"
pwd
bash run_transparent_singularity.sh --container itksnap_3.8.0_20200811.simg


# check if container file exists
if [ -f /home/runner/work/transparent-singularity/itksnap_3.8.0_20200811.simg ]; then
    echo "[DEBUG]: Container file exists"
else 
    echo "[DEBUG]: Container file does not exist! Something went wrong when downloading."
    exit 1
fi

# check if transparent singularity generated executable output file:
FILE="/home/runner/work/transparent-singularity/itksnap"
if [ -f $FILE ];then
    echo "[DEBUG]: $FILE exists."
else
    echo "[DEBUG]: $FILE doesn't exist. Something went wrong with transparent singularity. Trying again."
    rm -rf /home/runner/work/neurocommand/itksnap_3.8.0_20200811.simg
    bash /home/runner/work/neurocommand/neurocommand/local/fetch_containers.sh itksnap 3.8.0 20200811 itksnap /MRIcrop-orig.gipl
    if [ -f $FILE ];then
        echo "[DEBUG]: $FILE exists."
    else 
        echo "[DEBUG]: $FILE doesn't exist. Something went wrong with transparent singularity. Trying again."
    fi
fi