#!/bin/bash -i

# fetch_and_run.sh line $LINENO [name] [version] [date] {cmd} {args}
# Example:
#   fetch_and_run.sh line $LINENO itksnap 3.8.0 20200505 itksnap-wt

# source ~/.bashrc
_script="$(readlink -f "${BASH_SOURCE[0]}")" ## who am i? ##
_base="$(dirname "$_script")" ## Delete last component from $_script ##
echo "[INFO] fetch_and_run.sh line $LINENO: Script name : $_script"
echo "[INFO] fetch_and_run.sh line $LINENO: Current working dir : $PWD"
echo "[INFO] fetch_and_run.sh line $LINENO: Script location path (dir) : $_base"
echo "[CHECK] fetch_and_run.sh line $LINENO: SINGULARITY_BINDPATH : $SINGULARITY_BINDPATH"

# -z checks if SINGULARITY_BINDPATH is not set
if [ -z "$SINGULARITY_BINDPATH" ]
then
        echo "[WARNING] fetch_and_run.sh line $LINENO: SINGULARITY_BINDPATH is not set. Trying to set it"
        export SINGULARITY_BINDPATH="$PWD"
      
        #   if /cvmfs exists add this as well:
        if [ -d "/cvmfs" ]; then
            export SINGULARITY_BINDPATH="$SINGULARITY_BINDPATH",/cvmfs
        fi
        echo "[CHECK] fetch_and_run.sh line $LINENO: SINGULARITY_BINDPATH : $SINGULARITY_BINDPATH"
fi

# shellcheck disable=SC1091
source "${_base}"/configparser.sh "${_base}"/config.ini

MOD_NAME=$1
MOD_VERS=$2
MOD_DATE=$3
IMG_NAME=${MOD_NAME}_${MOD_VERS}_${MOD_DATE}

# This is to capture legacy use. If CVMFS_DISABLE is not set, we assume it is false, which was the legacy behaviour.
if [ -z "$CVMFS_DISABLE" ]; then
    export CVMFS_DISABLE="false"
fi

if [[ "$CVMFS_DISABLE" == "false" ]]; then
    if [[ -f "/cvmfs/neurodesk.ardc.edu.au/containers/$IMG_NAME/commands.txt" ]]; then
        echo "[INFO] fetch_and_run.sh line $LINENO: CVMFS detected and container seems to be available"
    else
        echo "[WARNING] fetch_and_run.sh line $LINENO: CVMFS does not seem to work or is disabled or the container is not available yet on CVMFS."
        CVMFS_DISABLE=true
    fi
fi

if [[ "$CVMFS_DISABLE" == "false" ]]; then
        echo "[INFO] fetch_and_run.sh line $LINENO: Mounting containers from CVMFS directly, but using local containers higher priority."
        LOCAL_CONTAINER_FILE_NAME="${_base}"/containers/${IMG_NAME}/${IMG_NAME}.simg
        if [ -e "${LOCAL_CONTAINER_FILE_NAME}" ]; then
            export CONTAINER_PATH="${_base}"/containers/
        else
            export CONTAINER_PATH=/cvmfs/neurodesk.ardc.edu.au/containers
        fi
        MODS_PATH="${_base}"/containers/modules:$CONTAINER_PATH/modules
        module use ${MODS_PATH}
else
        echo "[WARNING] fetch_and_run.sh line $LINENO: Not using CVMFS! Downloading containers fully!"
        # shellcheck disable=SC1091
        export CONTAINER_PATH="${_base}"/containers
        echo "[INFO] fetch_and_run.sh line $LINENO: CONTAINER_PATH=$CONTAINER_PATH"
        source "${_base}"/fetch_containers.sh "$1" "$2" "$3"
        module use ${MODS_PATH}
fi


echo "[INFO] fetch_and_run.sh line $LINENO: fetching containers done."
echo "[INFO] fetch_and_run.sh line $LINENO: MOD_NAME: " "$MOD_NAME"
echo "[INFO] fetch_and_run.sh line $LINENO: MOD_VERS: " "$MOD_VERS"


echo "[INFO] fetch_and_run.sh line $LINENO: Module '${MOD_NAME}/${MOD_VERS}' is installed. Use the command 'module load ${MOD_NAME}/${MOD_VERS}' outside of this shell to use it."

# If no additional command -> Give user a shell in the image after loading the module to set SINGULARITY/APPTAINER_BINDPATH
if [ $# -le 3 ]; then
    CONTAINER_FILE_NAME=${CONTAINER_PATH}/${IMG_NAME}/${IMG_NAME}.simg
    echo "[INFO] fetch_and_run.sh line $LINENO: looking for ${CONTAINER_FILE_NAME}"
    if [ -e "${CONTAINER_FILE_NAME}" ]; then
        cd 
        echo "[INFO] fetch_and_run.sh line $LINENO: Module loading the container to set environment variables."
        module load "${MOD_NAME}"/"${MOD_VERS}"
        echo "[INFO] fetch_and_run.sh line $LINENO: Attempting to launch container ${CONTAINER_FILE_NAME} with neurodesk_singularity_opts=${neurodesk_singularity_opts}"
        
        export SINGULARITYENV_PS1="${MOD_NAME}-${MOD_VERS}:\w$ "
        # shellcheck disable=SC2154
        echo "[INFO] fetch_and_run.sh line $LINENO: output README.md of the container"
        singularity --silent exec --cleanenv --env DISPLAY=$DISPLAY ${neurodesk_singularity_opts} ${CONTAINER_FILE_NAME} cat /README.md
        
        # echo "[INFO] fetch_and_run.sh line $LINENO: shell into the container"
        singularity --silent shell ${neurodesk_singularity_opts} "${CONTAINER_FILE_NAME}"
        if [ $? -eq 0 ]; then
            echo "[INFO] fetch_and_run.sh line $LINENO: Container ran OK"
        else
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "[ERROR] fetch_and_run.sh line $LINENO: the container ${CONTAINER_FILE_NAME} experienced an error when starting. This could be a problem with your firewall if it uses deep packet inspection. Please ask your IT if they do this and what they are blocking. Trying a workaround next - hit Enter to try that!"
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            
            read -n 1 -s -r -p "Press any key to continue..."
            echo ""
        
            export CVMFS_DISABLE=true
            
            echo "[INFO] downloading the complete container as a workaround ..."
            # shellcheck disable=SC1091
            source "${_base}"/fetch_containers.sh "$1" "$2" "$3"
            CONTAINER_PATH="${_base}"/containers
            CONTAINER_FILE_NAME=${CONTAINER_PATH}/${IMG_NAME}/${IMG_NAME}.simg
            singularity --silent exec ${neurodesk_singularity_opts} ${CONTAINER_FILE_NAME} cat /README.md
            singularity --silent shell ${neurodesk_singularity_opts} ${CONTAINER_FILE_NAME}
            if [ $? -eq 0 ]; then
                echo "[INFO] fetch_and_run.sh line $LINENO: Container ran OK"
            else
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                echo "[ERROR] fetch_and_run.sh line $LINENO: the container ${CONTAINER_FILE_NAME} doesn't exist. There is something wrong with the container download. Please ask for help here with the output of this window: https://github.com/orgs/NeuroDesk/discussions "
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                read -n 1 -s -r -p "Press any key to continue..."
            fi
        fi
    else 
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "[ERROR] fetch_and_run.sh line $LINENO: the container ${CONTAINER_FILE_NAME} doesn't exist. There is something wrong with the container download or CVMFS. Please ask for help here with the output of this window: https://github.com/orgs/NeuroDesk/discussions "
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        read -n 1 -s -r -p "Press any key to continue..."
    fi
fi

# If additional command -> Run it via module system
echo "[INFO] fetch_and_run.sh line $LINENO: module load ${MOD_NAME}/${MOD_VERS}"
module load ${MOD_NAME}/${MOD_VERS}
echo "[INFO] fetch_and_run.sh line $LINENO: Running command '${@:4}'."
${@:4}
