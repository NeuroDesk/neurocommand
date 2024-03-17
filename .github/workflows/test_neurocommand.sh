#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update
sudo apt install -y apptainer apptainer-suid

echo "checking if neurodesk installs and a containers gets downloaded correctly"

echo "python version is ... "
python --version
echo "apptainer version is ... "
apptainer --version
echo "where am I"
pwd
bash build.sh --cli --lxde
bash containers.sh all
bash /home/runner/work/neurocommand/neurocommand/local/fetch_containers.sh itksnap 3.8.0 20200811 itksnap /MRIcrop-orig.gipl


# check if container file exists
if [ -f /home/runner/work/neurocommand/neurocommand/local/containers/itksnap_3.8.0_20200811/itksnap_3.8.0_20200811.simg ]; then
    echo "[DEBUG]: test_neurocommand.sh Container file exists"
else 
    echo "[DEBUG]: test_neurocommand.sh Container file does not exist! Something went wrong when downloading."
    exit 1
fi

# check if transparent singularity generated executable output file:
FILE="/home/runner/work/neurocommand/neurocommand/local/containers/itksnap_3.8.0_20200811/itksnap"
if [ -f $FILE ];then
    echo "[DEBUG]: test_neurocommand.sh $FILE exists."
else
    echo "[DEBUG]: test_neurocommand.sh $FILE doesn't exist. Something went wrong with transparent singularity. Trying again."
    rm -rf /home/runner/work/neurocommand/neurocommand/local/containers/itksnap_3.8.0_20200811/itksnap_3.8.0_20200811.simg
    bash /home/runner/work/neurocommand/neurocommand/local/fetch_containers.sh itksnap 3.8.0 20200811 itksnap /MRIcrop-orig.gipl
    if [ -f $FILE ];then
        echo "[DEBUG]: test_neurocommand.sh $FILE exists."
    else 
        echo "[DEBUG]: test_neurocommand.sh $FILE doesn't exist. Something went wrong with transparent singularity. Trying again."
    fi
fi
