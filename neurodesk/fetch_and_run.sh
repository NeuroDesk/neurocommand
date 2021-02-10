#!/bin/bash

# fetch_and_run.sh [name] [version] [date] {cmd} {args}
# Example:
#   fetch_and_run.sh itksnap 3.8.0 20200505 itksnap-wt

source ~/.bashrc
_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
echo "[DEBUG] fetch_and_run.sh: Script name : $_script"
echo "[DEBUG] fetch_and_run.sh: Current working dir : $PWD"
echo "[DEBUG] fetch_and_run.sh: Script location path (dir) : $_base"
echo "[DEBUG] fetch_and_run.sh: SINGULARITY_BINDPATH : $SINGULARITY_BINDPATH"

if [ -z "$SINGULARITY_BINDPATH" ]
then
      echo "[DEBUG] fetch_and_run.sh: SINGULARITY_BINDPATH is not set. Trying to set it"
      directories=`curl https://raw.githubusercontent.com/NeuroDesk/caid/master/recipes/globalMountPointList.txt`
      mounts=`echo $directories | sed 's/ /,/g'`
      export SINGULARITY_BINDPATH=${mounts}
fi

source ${_base}/configparser.sh ${_base}/config.ini
source ${_base}/fetch_containers.sh $1 $2 $3
echo "[DEBUG] fetch_and_run.sh: fetching containers done."
echo "[DEBUG] fetch_and_run.sh: MOD_NAME: " $MOD_NAME
echo "[DEBUG] fetch_and_run.sh: MOD_VERS: " $MOD_VERS


echo "[DEBUG] fetch_and_run.sh: Module '${MOD_NAME}/${MOD_VERS}' is installed. Use the command 'module load ${MOD_NAME}/${MOD_VERS}' outside of this shell to use it."

# If no additional command -> Give user a shell in the image
if [ $# -le 3 ]; then
    CONTAINER_FILE_NAME=${CONTAINER_PATH}/${IMG_NAME}/${IMG_NAME}.simg
    echo "[DEBUG] fetch_and_run.sh: looking for ${CONTAINER_FILE_NAME}"
    if [ -f "${CONTAINER_FILE_NAME}" ]; then
        cd 
        echo "[DEBUG] fetch_and_run.sh: Attempting to launch container ${IMG_NAME}"
        singularity exec ${CONTAINER_FILE_NAME} cat /README.md
        singularity shell ${CONTAINER_FILE_NAME}
        if [ $? -eq 0 ]; then
            echo "[DEBUG] fetch_and_run.sh: Container ran OK"
        else
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "the container ${CONTAINER_FILE_NAME} experienced an error. If you want to trigger a reinstall, run:"
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_*" 
            echo "rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}" 
            read -p "Would you like me to do this for you (Y for yes)? " choice 
            [[ "$choice" == [Yy]* ]] && rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_* && rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}
        fi
    else 
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "the container ${CONTAINER_FILE_NAME} needs to be updated on your system. To trigger a reinstall, run:"
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_*" 
        echo "rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}" 
        read -p "Would you like me to do this for you (Y for yes)? " choice 
        [[ "$choice" == [Yy]* ]] && rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_* && rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}
    fi
fi

# If additional command -> Run it
echo "[DEBUG] fetch_and_run.sh: module load ${MOD_NAME}/${MOD_VERS}"
module load ${MOD_NAME}/${MOD_VERS}
echo "[DEBUG] fetch_and_run.sh: Running command '${@:4}'."
${@:4}
