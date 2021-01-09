#!/bin/bash

# fetch_and_run.sh [name] [version] [date] {cmd} {args}
# Example:
#   fetch_and_run.sh itksnap 3.8.0 20200505 itksnap-wt

echo "fetching containers:"

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
echo "Script name : $_script"
echo "Current working dir : $PWD"
echo "Script location path (dir) : $_base"

source ${_base}/configparser.sh
source ${_base}/fetch_containers.sh $1 $2 $3
echo "fetching containers done."
echo "MOD_NAME: " $MOD_NAME
echo "MOD_NAME: " $MOD_VERS


echo "Module '${MOD_NAME}/${MOD_VERS}' is installed. Use the command 'module load ${MOD_NAME}/${MOD_VERS}' outside of this shell to use it."

# If no additional command -> Give user a shell in the image
if [ $# -le 3 ]; then
    source ~/.bashrc
    CONTAINER_FILE_NAME=${CONTAINER_PATH}/${IMG_NAME}/${IMG_NAME}.simg
    echo "looking for ${CONTAINER_FILE_NAME}"
    if [ -f "${CONTAINER_FILE_NAME}" ]; then
        cd 
        echo "Attempting to launch container ${IMG_NAME}"
        singularity exec ${CONTAINER_FILE_NAME} cat /README.md
        singularity shell ${CONTAINER_FILE_NAME}
        if [ $? -eq 0 ]; then
            echo "Container ran OK"
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
echo "module load ${MOD_NAME}/${MOD_VERS}"
module load ${MOD_NAME}/${MOD_VERS}
echo "Running command '${@:4}'."
${@:4}
