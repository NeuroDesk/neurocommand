#!/bin/bash

# fetch_and_run.sh [name] [version] [date] {cmd} {args}
# Example:
#   fetch_and_run.sh itksnap 3.8.0 20200505 itksnap-wt

# Read arguments
MOD_NAME=$1
MOD_VERS=$2
MOD_DATE=$3

IMG_NAME=${MOD_NAME}_${MOD_VERS}_${MOD_DATE}

# Initialize lmod
source /usr/share/module.sh
VNM_PATH=/vnm
MODS_PATH=${VNM_PATH}/modules
module use ${MODS_PATH}

# Check if the module is installed
module avail -t 2>&1 | grep -i ${MOD_NAME}/${MOD_VERS}
if [ $? -ne 0 ]; then
    CWD=$PWD
    cd ${VNM_PATH}
    git clone https://github.com/Neurodesk/transparent-singularity.git ${IMG_NAME}
    cd ${IMG_NAME}
    ./run_transparent_singularity.sh --container ${IMG_NAME}.sif
    rm -rf .git* README.md run_transparent_singularity ts_*
fi
echo "Module '${MOD_NAME}/${MOD_VERS}' is installed. Use the command 'module load ${MOD_NAME}/${MOD_VERS}' outside of this shell to use it."

# If no additional command -> Give user a shell in the image
if [ $# -le 3 ]; then
    source ~/.bashrc
    clear
    CONTAINER_FILE_NAME=${VNM_PATH}/${IMG_NAME}/${IMG_NAME}.sif
    if [ -f "${CONTAINER_FILE_NAME}" ]; then
        echo "attempting to start shell in container ${IMG_NAME}"
        singularity shell ${CONTAINER_FILE_NAME}
    else 
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "the container you have has a bug and needs to be updated on your system. To trigger a reinstall, run:"
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "rm -rf /vnm/${MOD_NAME}_${MOD_VERS}_*" 
        echo "rm -rf /vnm/modules/${MOD_NAME}/${MOD_VERS}" 
        read -p "Would you like me to do this for you (Y for yes)? " choice 
        [[ "$choice" == [Yy]* ]] && rm -rf /vnm/${MOD_NAME}_${MOD_VERS}_* && rm -rf /vnm/modules/${MOD_NAME}/${MOD_VERS}
    fi

fi

# If additional command -> Run it
module load ${MOD_NAME}/${MOD_VERS}
echo "Running command '${@:4}'."
${@:4}
