#!/usr/bin/env bash
source deactivate_itksnap_3.8.0_20201208.simg.sh /home/sebp/neurocommand/neurodesk/containers/itksnap_3.8.0_20201208
export PWD=`pwd -P`
export PATH="$PWD:$PATH"
echo "# Container in $PWD" >> ~/.bashrc
echo "export PATH="$PWD:\$PATH"" >> ~/.bashrc
