#!/usr/bin/env bash
source deactivate_itksnap_4.0.2_20240117.simg.sh /home/sebp/neurocommand/neurodesk/containers/itksnap_4.0.2_20240117
export PWD=`pwd -P`
export PATH="$PWD:$PATH"
echo "# Container in $PWD" >> ~/.bashrc
echo "export PATH="$PWD:\$PATH"" >> ~/.bashrc
