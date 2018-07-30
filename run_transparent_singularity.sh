#!/bin/bash
#Deploy script for singularity Containers "Transparent Singularity"
#Creates wrapper scripts for all executables in a container's $DEPLOY_PATH
# singularity needs to be available
# for downloading images from nectar it needs curl installed
#11/07/2018
#by Steffen Bollmann <Steffen.Bollmann@cai.uq.edu.au> & Tom Shaw <t.shaw@uq.edu.au>


#Parameters
#container=tgvqsm_20180730.simg
container=$1
container_pull="curl -v -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/$container -O"

# define mount points for this system
echo 'warning: it is important to set your system specific mount points in your .bashrc!: e.g. export SINGULARITY_BINDPATH="/opt,/data"'



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
singularity exec --pwd $deploy_path $container ./ts_binaryFinder.sh


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
   echo "singularity exec --pwd \$PWD $deploy_path/$container $executable \$@" >> $executable
   chmod a+x $executable
done <commands.txt

echo "creating eactivate script that runs deactive first in case it is already there"
echo -e 'source deactivate_${container}.sh $deploy_path'
echo -e 'export PWD=`pwd -P`' > activate_${container}.sh
echo -e 'export PATH="$PWD:$PATH"' >> activate_${container}.sh
echo -e 'echo "# Container in $PWD" >> ~/.bashrc' >> activate_${container}.sh
echo -e 'echo "export PATH="$PWD:\$PATH"" >> ~/.bashrc' >> activate_${container}.sh

echo "deactivate script"
echo  pathToRemove=$deploy_path | cat - ts_deactivate_ > temp && mv temp deactivate_${container}.sh
chmod a+x deactivate_${container}.sh

echo "adding $container to your PATH"
chmod a+x activate_${container}.sh
source activate_${container}.sh

