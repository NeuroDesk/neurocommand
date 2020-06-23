#!/usr/bin/env bash
#Deploy script for singularity Containers "Transparent Singularity"
#Creates wrapper scripts for all executables in a container's $DEPLOY_PATH
# singularity needs to be available
# for downloading images from nectar it needs curl installed
#11/07/2018
#by Steffen Bollmann <Steffen.Bollmann@cai.uq.edu.au> & Tom Shaw <t.shaw@uq.edu.au>
# set -e

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
    container="$1"
fi

if [ -z "$container" ]; then
      echo "-----------------------------------------------"
      echo "Select the container you would like to install:"
      echo "-----------------------------------------------"
      curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages
      echo "-----------------------------------------------"
      echo "usage examples:"
      echo "./run_transparent_singularity.sh CONTAINERNAME"
      echo "./run_transparent_singularity.sh --container convert3d_1.0.0_20200622.sif --storage docker"
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

echo "cvl-variable is set to: $cvl"

if [[ "$cvl" == "true" ]]; then
   application_name=`echo $container | cut -d _ -f 1`
   application_version=`echo $container | cut -d _ -f 2`
   echo "create start script for cvl"
   echo "#!/usr/bin/env bash" > cvl-${container}.sh
   # test bindpaths and add if they exist:
   # echo 'export SINGULARITY_BINDPATH="/state/,/RDS,/30days,/90days,/QRISdata,$SINGULARITY_BINDPATH"' >>  cvl-${container}.sh
   # test if module system is there, if it fails try system installed singularity
   # echo "xterm -title '${application_name} ${application_version}' -e /bin/bash -c 'module load singularity/3.5.0;$deploy_path/$container'" >>  cvl-${container}.sh
   echo "xterm -title '${application_name} ${application_version}' -e /bin/bash -c '$deploy_path/$container'" >>  cvl-${container}.sh
   chmod 775 cvl-${container}.sh
   mv cvl-${container}.sh ../../bin
   echo "rm ../../bin/cvl-${container}.sh" >> ts_uninstall.sh

   echo "create desktop entry for cvl:"
   echo "[Desktop Entry]" > cvl-${container}.desktop
   echo "Comment=${application_name} ${application_version} - CVL - Computing Power to the people" >> cvl-${container}.desktop
   currentPath=`pwd -P`
   echo "Exec=${currentPath}/../../bin/cvl-${container}.sh" >> cvl-${container}.desktop
   echo "# You will need to update this to the right icon name/type" >> cvl-${container}.desktop
   echo "Icon=/sw7/CVL/config/icons/cvl-neuroimaging.jpg" >> cvl-${container}.desktop
   echo "Name=${application_name} ${application_version}" >> cvl-${container}.desktop
   echo "StartupNotify=true" >> cvl-${container}.desktop
   echo "#Terminal=1" >> cvl-${container}.desktop
   echo "# TerminalOptions=--noclose -T '${container} Debug Window'" >> cvl-${container}.desktop
   echo "Type=Application" >> cvl-${container}.desktop
   echo "Categories=${application_name}" >> cvl-${container}.desktop
   echo "X-KDE-SubstituteUID=false" >> cvl-${container}.desktop
   echo "X-KDE-Username=" >> cvl-${container}.desktop
   chmod 775 cvl-${container}.desktop
   mv cvl-${container}.desktop ../../xdg_data_dirs/applications/
   echo "rm ../../xdg_data_dirs/applications/cvl-${container}.desktop" >> ts_uninstall.sh

   echo "create directory entry for cvl:"
   echo "[Desktop Entry]" > cvl-${container}.directory
   echo "Comment=${application_name} ${application_version} - CVL - Computing Power to the people" >> cvl-${container}.directory
   echo "GenericName=" >> cvl-${container}.directory
   echo "Icon=/sw7/CVL/config/icons/cvl-neuroimaging.jpg" >> cvl-${container}.directory
   echo "Type=Directory" >> cvl-${container}.directory
   echo "Name=${application_name}" >> cvl-${container}.directory
   chmod 775 cvl-${container}.directory
   mv cvl-${container}.directory ../../xdg_data_dirs/desktop-directories/
   echo "rm ../../xdg_data_dirs/desktop-directories/cvl-${container}.directory" >> ts_uninstall.sh

   echo "If this is the first time you install this software, add a menu entry in ../xdg_config_dirs/menus/cvl.menu - category name: ${application_name}"
   echo "----------------------------------"
   echo "<Menu>"
   echo "   <Name>CVL ${application_name}</Name>"
   echo "   <Directory>cvl-${application_name}.directory</Directory>"
   echo "   <Include>"
   echo "     <And>"
   echo "       <Category>${application_name}</Category>"
   echo "     </And>"
   echo "   </Include>"
   echo " </Menu>"

fi