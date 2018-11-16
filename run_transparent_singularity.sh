#!/bin/bash
#Deploy script for singularity Containers "Transparent Singularity"
#Creates wrapper scripts for all executables in a container's $DEPLOY_PATH
# singularity needs to be available
# for downloading images from nectar it needs curl installed
#11/07/2018
#by Steffen Bollmann <Steffen.Bollmann@cai.uq.edu.au> & Tom Shaw <t.shaw@uq.edu.au>


#Parameters
container=$1
container_pull="curl -v -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/$container -O"

# define mount points for this system
echo 'warning: it is important to set your system specific mount points in your .bashrc!: e.g. export SINGULARITY_BINDPATH="/opt,/data"'



echo "checking for singularity ..."
qq=`which  singularity`
if [[  ${#qq} -lt 1 ]]; then
   echo "This requires singularity on your path. E.g. add module load singularity/2.4.2 to your .bashrc"
   exit
fi

deploy_path=`pwd -P`
echo "deploying in $deploy_path"
echo "checking if container needs to be downloaded"
qq=`ls $container`
if  [[  ${#qq} -lt 1 ]]; then
   echo "pulling image"
   $container_pull
fi


echo "checking which executables exist inside container"
singularity exec --pwd $deploy_path $container ./ts_binaryFinder.sh

echo "create singularity executable for each regular executable in commands.txt"
# $@ parses command line options.
#test   executable="fslmaths"
while read executable; do \
   echo $executable > $PWD/${executable}; \
   echo "export PWD=\`pwd -P\`" > $executable 
   echo "singularity exec -e --pwd \$PWD $deploy_path/$container $executable \$@" >> $executable
   chmod a+x $executable
done <commands.txt

echo "creating activate script that runs deactivate first in case it is already there"
echo "source deactivate_${container}.sh $deploy_path" > activate_${container}.sh
echo -e 'export PWD=`pwd -P`' >> activate_${container}.sh
echo -e 'export PATH="$PWD:$PATH"' >> activate_${container}.sh
echo -e 'echo "# Container in $PWD" >> ~/.bashrc' >> activate_${container}.sh
echo -e 'echo "export PATH="$PWD:\$PATH"" >> ~/.bashrc' >> activate_${container}.sh
chmod a+x activate_${container}.sh

echo "deactivate script"
echo  pathToRemove=$deploy_path | cat - ts_deactivate_ > temp && mv temp deactivate_${container}.sh
chmod a+x deactivate_${container}.sh



echo "create module files on directory up"
modulePath=../modules/`echo $container | cut -d _ -f 1`
mkdir $modulePath -p
moduleName=`echo $container | cut -d _ -f 2-`
echo "#%Module####################################################################" > ${modulePath}/${moduleName}
echo "module-whatis  ${container}" >> ${modulePath}/${moduleName}
echo "prepend-path PATH ${deploy_path}" >> ${modulePath}/${moduleName}

