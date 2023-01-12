#!/usr/bin/env bash
#Deploy script for singularity Containers "Transparent Singularity"
#Creates wrapper scripts for all executables in a container's $DEPLOY_PATH
# singularity needs to be available
# for downloading images from nectar it needs curl installed
#11/07/2018
#by Steffen Bollmann <Steffen.Bollmann@cai.uq.edu.au> & Tom Shaw <t.shaw@uq.edu.au>
# set -e

echo "[DEBUG] This is the run_transparent_singularity.sh script"

echo "Singularity bindpath is: $SINGULARITY_BINDPATH"
echo "Singularity bindpath should at least have vnm path!"


_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##

echo "making sure this is not running in a symlinked directory (singularity bug)"
echo "path: $_base"
cd $_base
_base=`pwd -P`
echo "corrected path: $_base"

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
      -u|--unpack)
      unpack="$2"
      shift # past argument
      shift # past value
      ;;
      -o|--singularity-opts)
      singularity_opts="$2"
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
      echo "singularity container list:"
      curl -s https://raw.githubusercontent.com/NeuroDesk/neurodesk/master/cvmfs/log.txt
      echo " "
      echo "-----------------------------------------------"
      echo "usage examples:"
      echo "./run_transparent_singularity.sh CONTAINERNAME"
      echo "./run_transparent_singularity.sh --container convert3d_1.0.0_20210104.simg --storage docker"
      echo "./run_transparent_singularity.sh convert3d_1.0.0_20210104.simg"
      echo "./run_transparent_singularity.sh convert3d_1.0.0_20210104 --unpack true --singularity-opts '--bind /cvmfs'"
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

containerName="$(cut -d'_' -f1 <<< ${container})"
echo "containerName: ${containerName}"

containerVersion="$(cut -d'_' -f2 <<< ${container})"
echo "containerVersion: ${containerVersion}"

containerDateAndFileEnding="$(cut -d'_' -f3 <<< ${container})"
containerDate="$(cut -d'.' -f1 <<< ${containerDateAndFileEnding})"
containerEnding="$(cut -d'.' -f2 <<< ${containerDateAndFileEnding})"

echo "containerDate: ${containerDate}"

# if no container extension is given, assume .simg
if [ "$containerEnding" = "$containerDate" ]; then
   containerEnding="simg"
   container=${containerName}_${containerVersion}_${containerDate}.${containerEnding}
fi

echo "checking for singularity ..."
qq=`which  singularity`
if [[  ${#qq} -lt 1 ]]; then
   echo "This script requires singularity or apptainer on your path. E.g. add 'module load singularity' to your .bashrc"
   echo "If you are root try again as normal user"
   exit 2
fi

echo "containerEnding: ${containerEnding}"

echo "checking if $container exists in the cvmfs cache ..."
if [[ -d "/cvmfs/neurodesk.ardc.edu.au/containers/${containerName}_${containerVersion}:${containerDate}" ]]; then
   echo "$container exists in cvmfs"
   storage="cvmfs"
   container_pull="ln -s /cvmfs/neurodesk.ardc.edu.au/containers/${containerName}_${containerVersion}:${containerDate} $container"
else
   echo "$container does not exists in cvmfs. Testing Oracle Object storage next: "
   if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/$container"; then
      echo "$container exists in the oracle cache"
      storage="oracle"
      echo "check if aria2 is installed ..."
      qq=`which  aria2c`
      if [[  ${#qq} -lt 1 ]]; then
          echo "aria2 is not installed. Defaulting to curl."
          urlUS="https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/"
          urlEUROPE="https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/"
          urlSYDNEY="https://objectstorage.ap-sydney-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/"
          urlBRISBANE="https://swift.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/neurodesk/"
          urls=($urlUS $urlEUROPE $urlSYDNEY $urlBRISBANE)
          declare -a speeds   
              
          echo "testing which server is fastest."
          for url in "${urls[@]}";          
          do  
             echo testing $url
             if avg_speed=$(curl -s -w %{time_total}\\n -o /dev/null "$url")
                then          
                   echo ResponseTime: "$avg_speed"
                   speeds+=($avg_speed)     
             fi               
          done
              
          count=0             
          for speed in "${speeds[@]}";      
          do 
             #echo comparing $speed with $avg_speed
             #echo currenlty fastest server is: $url
             #echo count: $count
             if (( $(echo "$speed < $avg_speed" |bc -l) )); then
                #echo found a new min: $speed
                avg_speed=$speed
                url=${urls[$count]}
                #echo setting URL to $url
             fi
             count=$((count+1))                                                                                                                                  
          done
          echo using server $url
              
          container_pull="curl -X GET ${url}${container} -O"
       else 
          container_pull="aria2c https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/$container https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/$container https://objectstorage.ap-sydney-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/$container https://swift.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/neurodesk/$container"
       fi
   else
      # fallback to docker
      echo "$container does not exist in any cache - loading from docker!"
      storage="docker"
      container_pull="singularity pull --name $container docker://vnmd/${containerName}_${containerVersion}:${containerDate}"
   fi
fi


echo "deploying in $_base"
echo "checking if container needs to be downloaded"
if  [[ -e $container ]]; then
   echo "container downloaded already. Remove to re-download!"
else
   echo "pulling image now ..."
   $container_pull
fi

# echo "making container executable"
# chmod a+x $container
# if [[  ${#qq} -lt 1 ]]; then
#    echo "Something went wrong when making the container executable."
# fi

if [[ $unpack = "true" ]]
then
   echo "unpacking singularity file to sandbox directory:"
    singularity build --sandbox temp $container
    rm -rf $container
    mv temp $container
fi

echo "checking which executables exist inside container"
echo "executing: singularity exec $singularity_opts --pwd $_base $container $_base/ts_binaryFinder.sh"
singularity exec $singularity_opts --pwd $_base $container $_base/ts_binaryFinder.sh

echo "checking if commands.txt exists now"
if  [[ -f $_base/commands.txt ]]; then
   echo "[DEBUG] run_transparent_singularity: This worked!"
else
   echo "[DEBUG] run_transparent_singularity: Trying to guess singularity bindpaths:"
   export SINGULARITY_BINDPATH=$PWD
   echo "SINGULARITY_BINDPATH: $SINGULARITY_BINDPATH"
   singularity exec $singularity_opts --pwd $_base $container $_base/ts_binaryFinder.sh
   if  [[ -f $_base/commands.txt ]]; then
      echo "[DEBUG] run_transparent_singularity: This worked!"
   else
      echo "[DEBUG] run_transparent_singularity: Something is wrong with the Singularity Bindpath. Please check!"
      exit 2
   fi
fi

echo "create singularity executable for each regular executable in commands.txt"
# $@ parses command line options.
#test   executable="fslmaths"
while read executable; do \
   echo $executable > $_base/${executable}; \
   echo "#!/usr/bin/env bash" > $executable
   echo "export PWD=\`pwd -P\`" >> $executable
   echo "singularity --silent exec $singularity_opts \$neurodesk_singularity_opts --pwd \$PWD $_base/$container $executable \"\$@\"" >> $executable
   # neurodesk_singularity_opts is a global variable that can be set in neurodesk for example --nv for gpu support
   # --silent is required to suppress bind mound warnings (e.g. for /etc/localtime)
   chmod a+x $executable
done < $_base/commands.txt

echo "creating activate script that runs deactivate first in case it is already there"
echo "#!/usr/bin/env bash" > activate_${container}.sh
echo "source deactivate_${container}.sh $_base" >> activate_${container}.sh
echo -e "export PWD=\`pwd -P\`" >> activate_${container}.sh
echo -e 'export PATH="$PWD:$PATH"' >> activate_${container}.sh
echo -e 'echo "# Container in $PWD" >> ~/.bashrc' >> activate_${container}.sh
echo -e 'echo "export PATH="$PWD:\$PATH"" >> ~/.bashrc' >> activate_${container}.sh
chmod a+x activate_${container}.sh

echo "deactivate script"
echo  pathToRemove=$_base | cat - ts_deactivate_ > temp && mv temp deactivate_${container}.sh
chmod a+x deactivate_${container}.sh



echo "create module files one directory up"
modulePath=$_base/../modules/`echo $container | cut -d _ -f 1`
echo $modulePath
mkdir $modulePath -p
moduleName=`echo $container | cut -d _ -f 2`
echo "#%Module####################################################################" > ${modulePath}/${moduleName}
echo "module-whatis  ${container}" >> ${modulePath}/${moduleName}
echo "prepend-path PATH ${_base}" >> ${modulePath}/${moduleName}
echo "rm ${modulePath}/${moduleName}" >> ts_uninstall.sh
