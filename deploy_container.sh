#!/bin/bash
#Deploy script for minc-toolkit
#Creates wrapper scripts for all executables in a container's $PATH
# singularity needs to be available
#11/07/2018
#SB & TS

#Parameters
container=minc-toolkit-1.9.16.simg
container_pull=shub://vfonov/minc-toolkit-containers:1.9.16

container=minc_1p9p16_20180712.simg

container_pull="scp steffen@203.101.224.252:/qrisvolume/caid/$container $container"

deploy_path=`pwd -P`
echo "deploying in $deploy_path"
echo "checking if container needs to be downloaded"
#pull image if not yet there
qq=`ls $container`
if  [[  ${#qq} -lt 1 ]]; then
   echo "pulling image"
   $container_pull
fi

echo "checking out which executables exist inside container"


singularity exec --pwd $deploy_path $container ./binaryFinder.sh

echo "create singularity executable for each regular executable in commands.txt"
# $@ parses command line options.
 
#for executable in `cat commands.txt`; do \
   executable="register"
   echo $executable > $PWD/${executable}; \
   echo "export PWD=\`pwd -P\`" > $executable 
   echo "singularity exec --pwd \$PWD $deploy_path/$container $executable \$@" >> $executable
   chmod a+x $executable

#done

#add /path/to/singularity_executables to your $PATH 
#export PATH="$PWD:$PATH"
#echo "# $container"
#echo "export PATH="$PWD:$PATH"" >> ~/.bashrc
