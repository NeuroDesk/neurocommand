#!/bin/bash
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
      -cvl|--cvl)
      cvl="$2"
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
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

if [ -z "$container" ]; then
      echo "-----------------------------------------------"
      echo "Select the container you would like to install:"
      echo "-----------------------------------------------"
      curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages
      echo "-----------------------------------------------"
      echo "usage examples:"
      echo "./run_transparent_singularity.sh -c CONTAINERNAME"
      echo "./run_transparent_singularity.sh --container CONTAINERNAME"
      echo "./run_transparent_singularity.sh --container convert3d_1.0.0_20200420.sif"
      echo "./run_transparent_singularity.sh --container convert3d_1.0.0_20200420.sif --storage sylabs"
      echo "./run_transparent_singularity.sh --container convert3d_1.0.0_20200420.sif --cvl true"
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

# default is swift storage
container_pull="curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/$container -O"


if [ "$storage" = "sylabs" ]; then
   echo "pulling from sylabs cloud"
   containerName="$(cut -d'_' -f1 <<< ${container})"
   echo "containerName: ${containerName}"

   containerVersion="$(cut -d'_' -f2 <<< ${container})"
   echo "containerVersion: ${containerVersion}"

   containerDateAndFileEnding="$(cut -d'_' -f3 <<< ${container})"
   containerDate="$(cut -d'.' -f1 <<< ${containerDateAndFileEnding})"
   echo "containerDate: ${containerDate}"
   container_pull="singularity pull library://sbollmann/caid/${containerName}:${containerVersion}_${containerDate}"
fi

echo "checking for singularity ..."
qq=`which  singularity`
if [[  ${#qq} -lt 1 ]]; then
   echo "This script requires singularity on your path. E.g. add module load singularity/2.4.2 to your .bashrc"
   echo "If you are root try again as normal user"
   exit
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


echo "checking which executables exist inside container"
singularity exec --pwd $deploy_path $container ./ts_binaryFinder.sh

echo "create singularity executable for each regular executable in commands.txt"
# $@ parses command line options.
#test   executable="fslmaths"
while read executable; do \
   echo $executable > $PWD/${executable}; \
   echo "export PWD=\`pwd -P\`" > $executable 
   echo "singularity exec --pwd \$PWD $deploy_path/$container $executable \$@" >> $executable
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



echo "create module files one directory up"
modulePath=../modules/`echo $container | cut -d _ -f 1`
mkdir $modulePath -p
moduleName=`echo $container | cut -d _ -f 2`
echo "#%Module####################################################################" > ${modulePath}/${moduleName}
echo "module-whatis  ${container}" >> ${modulePath}/${moduleName}
echo "prepend-path PATH ${deploy_path}" >> ${modulePath}/${moduleName}


if [ "$cvl" = "true" ]; then
   echo "create start script for cvl"
   echo "#!/bin/bash" > cvl-${container}.sh
   echo "xterm -title '${container}' -e /bin/bash -c 'module load singularity/3.5.0;$deploy_path/$container --bind /30days /90days /QRISdata'" >>  cvl-${container}.sh
   chmod a+x cvl-${container}.sh

   echo "create desktop entry for cvl:"
   echo "[Desktop Entry]" > cvl-${container}.destkop
   echo "Comment=" >> cvl-${container}.destkop
   echo "Exec=$deploy_path/$container/cvl-${container}.sh" >> cvl-${container}.destkop
   echo "# You will need to update this to the right icon name/type" >> cvl-${container}.destkop
   echo "Icon=/sw7/CVL/config/icons/cvl-neuroimaging.jpg" >> cvl-${container}.destkop
   echo "Name=CVL ${container}" >> cvl-${container}.destkop
   echo "StartupNotify=true" >> cvl-${container}.destkop
   echo "#Terminal=1" >> cvl-${container}.destkop
   echo "# TerminalOptions=--noclose -T '${container} Debug Window'" >> cvl-${container}.destkop
   echo "Type=Application" >> cvl-${container}.destkop
   echo "Categories=Imaging" >> cvl-${container}.destkop
   echo "X-KDE-SubstituteUID=false" >> cvl-${container}.destkop
   echo "X-KDE-Username=" >> cvl-${container}.destkop

   echo "create directory entry for cvl:" 
   echo "[Desktop Entry]" > cvl-${container}.directory
   echo "Comment=CVL ${container}" >> cvl-${container}.directory
   echo "GenericName=" >> cvl-${container}.directory
   echo "Icon=/sw7/CVL/config/icons/cvl-neuroimaging.jpg" >> cvl-${container}.directory
   echo "Type=Directory" >> cvl-${container}.directory
   echo "Name=CVL ${container}" >> cvl-${container}.directory
fi