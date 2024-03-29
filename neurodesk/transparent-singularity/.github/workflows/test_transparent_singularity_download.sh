#!/usr/bin/env bash
set -e

echo "checking if neurodesk installs and a containers gets downloaded correctly"

echo "python version is ... "
python --version
echo "singularity version is ... "
singularity --version
echo "where am I"
pwd
bash run_transparent_singularity.sh --container itksnap_3.8.0_20201208.simg


# check if container file exists
if [ -f /home/runner/work/transparent-singularity/transparent-singularity/itksnap_3.8.0_20201208.simg ]; then
    echo "[DEBUG]: Container file exists"
else 
    echo "[DEBUG]: Container file does not exist! Something went wrong when downloading."
    exit 1
fi

# check if transparent singularity generated executable output file:
FILE="/home/runner/work/transparent-singularity/transparent-singularity/itksnap"
if [ -f $FILE ];then
    echo "[DEBUG]: $FILE exists."
else
    echo "[DEBUG]: $FILE doesn't exist. Something went wrong with transparent singularity. "
    exit 1
fi