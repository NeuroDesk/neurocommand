#!/usr/bin/env bash
#Deploy script for singularity Containers "Transparent Singularity"
#Creates wrapper scripts for all executables in a container's $DEPLOY_PATH
# singularity needs to be available
# for downloading images from nectar it needs curl installed
#11/07/2018
#by Steffen Bollmann <Steffen.Bollmann@cai.uq.edu.au> & Tom Shaw <t.shaw@uq.edu.au>
set -e

POSITIONAL=()
while [[ $# -gt 0 ]]
   do
   key="$1"

   case $key in
      -s|--storage)
      storage="$2"
      shift # past argument
      shift # past value
      ;;
      -c|--container)
      container="$2"
      shift # past argument
      shift # past value
      ;;
      --default)
      DEFAULT=YES
      shift # past argument
      ;;
      *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
   esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


if [[ -n $1 ]]; then
    container="$1"
fi

if [ -z "$container" ]; then
      echo "-----------------------------------------------"
      echo "Select the container you would like to install:"
      echo "-----------------------------------------------"
      echo "full list: https://github.com/NeuroDesk/caid/packages"
      echo "singularity container cache list:"
      curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages
      echo " "
      echo "-----------------------------------------------"
      echo "usage examples:"
      echo "./run_transparent_singularity.sh CONTAINERNAME"
      echo "./run_transparent_singularity.sh convert3d_1.0.0_20200701.sif"
      echo "./run_transparent_singularity.sh --container convert3d_1.0.0_20200701.sif --storage docker"
      echo "-----------------------------------------------"
      exit
   else
      echo "-------------------------------------"
      echo "installing container ${container}"
      echo "-------------------------------------"


      # define mount points for this system
      echo "-------------------------------------"
      echo 'IMPORTANT: you need to set your system specific mount points in your .bashrc!: e.g. export SINGULARITY_BINDPATH="/opt,/data"'
      echo "-------------------------------------"
fi

# check if image is available on singularity cache:
if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/$container"; then
   echo "$container exists in the cache"
   container_pull="curl -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/$container -O"
else
   echo "$container does not exist in cache - loading from docker!"
   storage="docker"
fi

if [ "$storage" = "docker" ]; then
   echo "pulling from docker cloud"
   containerName="$(cut -d'_' -f1 <<< ${container})"
   echo "containerName: ${containerName}"

   containerVersion="$(cut -d'_' -f2 <<< ${container})"
   echo "containerVersion: ${containerVersion}"

   containerDateAndFileEnding="$(cut -d'_' -f3 <<< ${container})"
   containerDate="$(cut -d'.' -f1 <<< ${containerDateAndFileEnding})"
   echo "containerDate: ${containerDate}"
   container_pull="singularity pull docker://vnmd/${containerName}_${containerVersion}:${containerDate}"
fi

echo "checking for singularity ..."
qq=`which  singularity`
if [[  ${#qq} -lt 1 ]]; then
   echo "This script requires singularity on your path. E.g. add module load singularity/2.4.2 to your .bashrc"
   echo "If you are root try again as normal user"
   echo "trying to module load:"
   module load singularity/3.5.0
   qq=`which  singularity`
   if [[  ${#qq} -lt 1 ]]; then
      exit
   fi
fi

deploy_path=`pwd -P`
echo "deploying in $deploy_path"
echo "checking if container needs to be downloaded"
if  [[ -f $container ]]; then
   echo "container downloaded already. Remove to re-download!"
else
   echo "pulling image now ... this will take some time!"
   $container_pull
fi

echo "making container executable"
chmod a+x $container

echo "checking which executables exist inside container"
singularity exec --pwd $deploy_path $container ./ts_binaryFinder.sh

echo "create singularity executable for each regular executable in commands.txt"
# $@ parses command line options.
#test   executable="fslmaths"
while read executable; do \
   echo $executable > $PWD/${executable}; \
   echo "#!/usr/bin/env bash" > $executable
   echo "export PWD=\`pwd -P\`" >> $executable
   echo "singularity exec --pwd \$PWD $deploy_path/$container $executable \$@" >> $executable
   chmod a+x $executable
done <commands.txt

echo "creating activate script that runs deactivate first in case it is already there"
echo "#!/usr/bin/env bash" > activate_${container}.sh
echo "source deactivate_${container}.sh $deploy_path" >> activate_${container}.sh
echo -e 'export PWD=`pwd -P`' >> activate_${container}.sh
echo -e 'export PATH="$PWD:$PATH"' >> activate_${container}.sh
echo -e 'echo "# Container in $PWD" >> ~/.bashrc' >> activate_${container}.sh
echo -e 'echo "export PATH="$PWD:\$PATH"" >> ~/.bashrc' >> activate_${container}.sh
chmod a+x activate_${container}.sh

echo "deactivate script"
echo  pathToRemove=$deploy_path | cat - ts_deactivate_ > temp && mv temp deactivate_${container}.sh
chmod a+x deactivate_${container}.sh



echo "create module files one directory up"
modulePath=../modules/`echo $container | cut -d _ -f 1`
mkdir $modulePath -p
moduleName=`echo $container | cut -d _ -f 2`
echo "#%Module####################################################################" > ${modulePath}/${moduleName}
echo "module-whatis  ${container}" >> ${modulePath}/${moduleName}
echo "append-path PATH ${deploy_path}" >> ${modulePath}/${moduleName}
echo "rm ${modulePath}/${moduleName}" >> ts_uninstall.sh