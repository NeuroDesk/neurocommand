#!/usr/bin/env bash
# set -e

echo "checking if neurodesk installs and a containers gets downloaded correctly"

echo "python version is ... "
python --version
echo "where am I"
pwd
bash build.sh --cli --lxde
bash containers.sh
bash /home/runner/work/neurodesk/neurodesk/local/fetch_containers.sh itksnap 3.8.0 20200811 itksnap /MRIcrop-orig.gipl

ls /home/runner/work/neurodesk/neurodesk/local/containers/itksnap_3.8.0_20200811

if [ -f /home/runner/work/neurodesk/neurodesk/local/containers/itksnap_3.8.0_20200811/itksnap_3.8.0_20200811.simg ]; then
    echo "Container file exists (from test_neurodesk_cli.sh)"
    exit 0
else 
    echo "Container file does not exist!!!!!!!!! (from test_neurodesk_cli.sh)"
    exit 1
fi

# cleanup
rm -rf /home/runner/work/neurodesk/neurodesk/local/
rm /home/runner/work/neurodesk/neurodesk/all_execs.sh