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
container=fsl_5p0p11_test.simg

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
#test   
executable="fslmath"
#for executable in `cat commands.txt`; do \
   echo $executable > $PWD/${executable}; \
   echo "export PWD=\`pwd -P\`" > $executable 
   echo "singularity exec --pwd \$PWD --bind /gpfs1:/gpfs1 $deploy_path/$container $executable \$@" >> $executable
   chmod a+x $executable
#done

echo "add $container to your PATH"
export PWD=`pwd -P`
export PATH="$PATH:$PWD"
echo "" >> ~/.bashrc
echo "# $container in $PWD" >> ~/.bashrc
echo "export PATH="\$PATH:$PWD"" >> ~/.bashrc

#There will also be a problem with multiple containers and different versions. We should set up an executable script with each container that turns the executables on and off easily.-
#something like:-
touch TURNOFF_${container}
touch TURNON_${container}
echo "PATH=`echo $PATH | sed -e 's/:$PWD/$//'`">> TURNOFF_${container}
echo "bash">>TURNOFF_${container}
echo "sed -e 's/:\$PWD\/$//' ~/.bashrc">> TURNOFF_${container}
echo "export PATH="$PWD:$PATH"">>/path/to/simg/TURNON_${container}
echo "export PATH="$PWD:$PATH"">>~/.bashrc
echo "bash">>TURNON_${container}

