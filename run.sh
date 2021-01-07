#!/usr/bin/env bash
set -e

export container="neurodesk_20210107.sif"

#test for singularity install
echo -n "checking for singularity ..."
qq=`which  singularity`
if [[  ${#qq} -lt 1 ]]; then
   echo "This script requires singularity on your path. E.g. add module load singularity/2.4.2 to your .bashrc"
   echo "If you are root try again as normal user"
   exit 2
else
   echo "... singularity is working :)"
fi

#test for wget, curl, or aria2
echo -n "checking for aria2 ..."
qq=`which  aria2c`
if [[  ${#qq} -lt 1 ]]; then
   echo "This script works best with aria2 - try to install for best performance"
   echo -n "aria2 is not install. Checking for cUrl...."
   qq=`which  curl`
   if [[  ${#qq} -lt 1 ]]; then
        echo "This script at least needs curl installed."
        exit 2
   else
        container_pull="curl -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/$container -O"
   fi
else
    echo "......... aria2 is working :)"
    container_pull="aria2c https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/$container https://objectstorage.us-ashburn-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/$container https://objectstorage.eu-zurich-1.oraclecloud.com/n/nrrir2sdpmdp/b/neurodesk/o/$container"
fi


#download neurodesk container
echo "checking if container needs to be downloaded"
if  [[ -f $container ]]; then
   echo "container downloaded already. Remove to re-download!"
else
   echo "pulling image now ... this will take some time!"
   $container_pull
fi
#run neurodesk container
