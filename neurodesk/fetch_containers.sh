#!/bin/bash

# fetch_containers.sh [name] [version] [date]
# Example - downloads the container:
#   fetch_and_run.sh itksnap 3.8.0 20200505

# Read arguments
MOD_NAME=$1
MOD_VERS=$2
MOD_DATE=$3

IMG_NAME=${MOD_NAME}_${MOD_VERS}_${MOD_DATE}

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
source ${_base}/configparser.sh

# default path is in the home directory of the user executing the call - except if there is a system wide install:
export PATH_PREFIX=${vnm_installdir}

source /etc/profile

export CONTAINER_PATH=$PATH_PREFIX/containers
export MODS_PATH=$CONTAINER_PATH/modules

echo "CONTAINER_PATH: $CONTAINER_PATH"
echo "MODS_PATH: $MODS_PATH"

echo "trying to module use  ${MODS_PATH}"
module use ${MODS_PATH}

if [ ! -L `readlink -f $CONTAINER_PATH` ]; then
    echo "creating `readlink -f $CONTAINER_PATH`"
    mkdir -p `readlink -f $CONTAINER_PATH` || echo "Something went wrong. " && exit
fi

if [ ! -d `readlink -f $MODS_PATH` ]; then
    echo "creating `readlink -f $MODS_PATH`"
    mkdir -p `readlink -f $MODS_PATH` || echo "Something went wrong. " && exit
fi
# Update application transparent-singularity with latest version
cd ${CONTAINER_PATH}
mkdir -p ${IMG_NAME}
# Check if the module is there - if not this means we definetly need to install the container

CONTAINER_FILE_NAME=${CONTAINER_PATH}/${IMG_NAME}/${IMG_NAME}.sif
if [ -f "${CONTAINER_FILE_NAME}" ]; then
    echo "found it. Container ${IMG_NAME} is there."
    echo "now checking if container is fully downloaded and executable:"
    qq=`which  singularity`
    if [[  ${#qq} -lt 1 ]]; then
        echo "ERROR: This script requires singularity on your path. EXITING"
        exit
    fi
    singularity exec ${CONTAINER_FILE_NAME} ls
    if [ $? -ne 0 ]; then
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "the container is incomplete and needs to be re-downloaded - run:"
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_*" 
        echo "rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}" 
        read -p "Would you like me to do this for you (Y for yes)? " choice 
        [[ "$choice" == [Yy]* ]] && rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_* && rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}
        exit
    else 
        echo "Container ${IMG_NAME} seems to be fully downloaded and executable."        
    fi
else
    cp ${vnm_installdir}/transparent-singularity/*.sh ${CONTAINER_PATH}/${IMG_NAME}/
    cp ${vnm_installdir}/transparent-singularity/ts_* ${CONTAINER_PATH}/${IMG_NAME}/
    cd ${IMG_NAME}
    ${CONTAINER_PATH}/${IMG_NAME}/run_transparent_singularity.sh --container ${IMG_NAME}.sif
    rm -rf .git* README.md run_transparent_singularity ts_*
fi

# This seems to cause problems if a module is there with the same name but not from neurodesk:
# module spider ${MOD_NAME}/${MOD_VERS}
# if [ $? -ne 0 ]; then
#     cp ${vnm_installdir}/transparent-singularity/*.sh ${CONTAINER_PATH}/${IMG_NAME}/
#     cp ${vnm_installdir}/transparent-singularity/ts_* ${CONTAINER_PATH}/${IMG_NAME}/
#     # cp ${vnm_installdir}/transparent-singularity/* ${IMG_NAME}/
#     #git clone https://github.com/Neurodesk/transparent-singularity.git ${IMG_NAME}
#     cd ${IMG_NAME}
#     ${CONTAINER_PATH}/${IMG_NAME}/run_transparent_singularity.sh --container ${IMG_NAME}.sif
#     rm -rf .git* README.md run_transparent_singularity ts_*
#     else # if the container is there, check if the image version is correct. If not, we need to remove the wrong version and download again:
#         CONTAINER_FILE_NAME=${CONTAINER_PATH}/${IMG_NAME}/${IMG_NAME}.sif
#         echo "looking for ${CONTAINER_FILE_NAME}"
#         if [ -f "${CONTAINER_FILE_NAME}" ]; then
#             echo "found it. Container ${IMG_NAME} is installed."
#         else 
#             echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#             echo "the container you have has a bug and needs to be updated on your system. To trigger a reinstall, run:"
#             echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
#             echo "rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_*" 
#             echo "rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}" 
#             read -p "Would you like me to do this for you (Y for yes)? " choice 
#             [[ "$choice" == [Yy]* ]] && rm -rf ${CONTAINER_PATH}/${MOD_NAME}_${MOD_VERS}_* && rm -rf ${MODS_PATH}/${MOD_NAME}/${MOD_VERS}
#             exit
#         fi
# fi


