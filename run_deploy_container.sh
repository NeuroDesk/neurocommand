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
container=fsl_5p0p11_20180712.simg
container_pull="scp steffen@203.101.224.252:/qrisvolume/caid/$container $container"

container=tgvqsm_fsl_5p0p11_20180717.simg
container_pull="scp steffen@203.101.224.252:/qrisvolume/qsm/$container $container"

container=tgvqsm_amd_20180727.simg
container_pull="scp steffen@203.101.224.252:/qrisvolume/qsm/$container $container"


echo "checking for singularity ..."
qq=`which  singularity`
if [[  ${#qq} -lt 1 ]]; then
   echo "This requires singularity on your path. E.g. add module load singularity/2.4.2 to your .bashrc"
fi


deploy_path=`pwd -P`
echo "deploying in $deploy_path"
echo "checking if container needs to be downloaded"
qq=`ls $container`
if  [[  ${#qq} -lt 1 ]]; then
   echo "pulling image"
   $container_pull
fi


# This features creates problems when binaries are meant to be in both containers and the order in the bashrc decides which-
# ones is loaded first
#echo "checking which executables exist outside container"
#IFS=':'; \
#for i in $PATH; \
#      do test -d "$i" && find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done > host_commands.txt


echo "checking which executables exist inside container"
singularity exec --pwd $deploy_path $container ./dc_binaryFinder.sh


#This features creates problems when binaries are meant to be in both containers and the order in the bashrc decides which 
# ones is loaded first
#echo "creating a set of commands that is unique for the container"
#awk 'FNR==NR {a[$0]++; next} !a[$0]' host_commands.txt container_commands.txt > commands.txt



echo "create singularity executable for each regular executable in commands.txt"
# $@ parses command line options.
#test   executable="fslmaths"
while read executable; do \
   echo $executable > $PWD/${executable}; \
   echo "export PWD=\`pwd -P\`" > $executable 
   echo "singularity exec --pwd \$PWD --bind /gpfs1:/gpfs1 $deploy_path/$container $executable \$@" >> $executable
   chmod a+x $executable
done <commands.txt

echo -e 'export PWD=`pwd -P`' > activate_${container}.sh
echo -e 'export PATH="$PATH:$PWD"' >> activate_${container}.sh
echo -e 'echo "# Container in $PWD" >> ~/.bashrc' >> activate_${container}.sh
echo -e 'echo "export PATH="\$PATH:$PWD"" >> ~/.bashrc' >> activate_${container}.sh

echo "removing container first, in case it is a reinstall"
echo  pathToRemove=$deploy_path | cat - dc_deactivate_ > temp && mv temp deactivate_${container}.sh
chmod a+x deactivate_${container}.sh
source deactivate_${container}.sh $deploy_path

echo "adding $container to your PATH"
chmod a+x activate_${container}.sh
source activate_${container}.sh

