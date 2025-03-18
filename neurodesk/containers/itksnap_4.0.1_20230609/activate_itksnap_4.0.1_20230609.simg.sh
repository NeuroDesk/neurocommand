#!/usr/bin/env bash
source deactivate_itksnap_4.0.1_20230609.simg.sh /home/sebp/neurocommand/neurodesk/containers/itksnap_4.0.1_20230609
export PWD=`pwd -P`
export PATH="$PWD:$PATH"
echo "# Container in $PWD" >> ~/.bashrc
echo "export PATH="$PWD:\$PATH"" >> ~/.bashrc
