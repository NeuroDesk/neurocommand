#!/usr/bin/env bash
# set -e

#This script runs on the CVMFS STRATUM 0 server every 1 minute

#sudo vi /etc/cron.d/sync_containers_to_cvmfs
#*/1 * * * * ec2-user cd ~ && bash /home/ec2-user/neurocommand/cvmfs/sync_containers_to_cvmfs.sh

#The cronjob logfile gets cleared after every week successful run


LOCKFILE=~/ISRUNNING.lock
if [[ -s $LOCKFILE ]]; then
    echo "there is currently a process running already."
    exit 2
else
    touch $LOCKFILE
    echo "running" >> $LOCKFILE
    rm ~/cronjob.log
fi

# echo "Syncing object storages:"
# export RCLONE_VERBOSE=2
# rclone sync oracle-2021-us-bucket:/neurodesk/temporary-builds oracle-2021-sydney-bucket:/neurodesk/temporary-builds
# rclone sync oracle-2021-us-bucket:/neurodesk oracle-2021-sydney-bucket:/neurodesk
# rclone copy oracle-2021-sydney-bucket:/neurodesk nectar:/neurodesk/

cd ~/neurocommand/

# update application list (the log.txt file gets build in the neurocommand action once all containers are uploaded.):
git pull
cd cvmfs

# check if there is enough free space - otherwise don't do anything:
FREE=`df -k --output=avail /storage | tail -n1`
if [[ $FREE -lt 400000000 ]]; then               # 400GB = 
    echo "There is not enough free disk space!"
    exit 1
fi;

# download and unpack containers on cvmfs
# curl -s https://raw.githubusercontent.com/NeuroDesk/neurocommand/master/cvmfs/log.txt
# export IMAGENAME_BUILDDATE=fsl_6.0.3_20200905
# export IMAGENAME_BUILDDATE=mrtrix3_3.0.1_20200908
# export IMAGENAME_BUILDDATE=spm12_r7219_20201120
# export LINE='fsl_6.0.4_20210105 categories:functional imaging,structural imaging,diffusion imaging,image segmentation,image registration,'

Field_Separator=$IFS
echo $Field_Separator


while IFS= read -r LINE
do
    echo "LINE: $LINE"
    IMAGENAME_BUILDDATE="$(cut -d' ' -f1 <<< ${LINE})"
    echo "IMAGENAME_BUILDDATE: $IMAGENAME_BUILDDATE"

    CATEGORIES=`echo $LINE | awk -F"categories:" '{print $2}'`
    echo "CATEGORIES: $CATEGORIES"

    echo "check if $IMAGENAME_BUILDDATE is in module files:"
    TOOLNAME="$(cut -d'_' -f1 <<< ${IMAGENAME_BUILDDATE})"
    TOOLVERSION="$(cut -d'_' -f2 <<< ${IMAGENAME_BUILDDATE})"
    BUILDDATE="$(cut -d'_' -f3 <<< ${IMAGENAME_BUILDDATE})"
    echo "[DEBUG] TOOLNAME: $TOOLNAME"
    echo "[DEBUG] TOOLVERSION: $TOOLVERSION"
    echo "[DEBUG] BUILDDATE: $BUILDDATE"

    echo "check if $IMAGENAME_BUILDDATE is already on cvmfs:"
    if [[ -f "/cvmfs/neurodesk.ardc.edu.au/containers/$IMAGENAME_BUILDDATE/commands.txt" ]]
    then
        echo "$IMAGENAME_BUILDDATE exists on cvmfs"
    else
        echo "$IMAGENAME_BUILDDATE is not yet on cvmfs."



        
        # check if singularity image is already in object storage
        if curl --output /dev/null --silent --head --fail "https://objectstorage.us-ashburn-1.oraclecloud.com/n/sd63xuke79z3/b/neurodesk/o/${IMAGENAME_BUILDDATE}.simg"; then
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg exists in ashburn oracle cloud"
            # in case of problems:
            # cvmfs_server check
            # If you get bad whitelist error, check if the repository is signed: sudo /usr/bin/cvmfs_server resign neurodesk.ardc.edu.au
            cvmfs_server transaction neurodesk.ardc.edu.au

            cd /cvmfs/neurodesk.ardc.edu.au/containers/
            git clone https://github.com/NeuroDesk/transparent-singularity $IMAGENAME_BUILDDATE
            cd $IMAGENAME_BUILDDATE
            export SINGULARITY_BINDPATH=/cvmfs
            echo $PATH
            export PATH=$PATH:/usr/sbin/
            ./run_transparent_singularity.sh $IMAGENAME_BUILDDATE --unpack true
            
            retVal=$?
            if [ $retVal -ne 0 ]; then
                echo "Error in Transparent singularity. Check the log. Aborting!"
                cd && cvmfs_server abort 
            else
                cd && cvmfs_server publish -m "added $IMAGENAME_BUILDDATE" neurodesk.ardc.edu.au
            fi
        else
            echo "[WARNING] ========================================================="
            echo "[DEBUG] ${IMAGENAME_BUILDDATE}.simg does not exist in oracle cloud"
            echo "[WARNING] ========================================================="
        fi
    fi

    # echo "check if custom prompt exists for singularity:"
    # if [[ -f "/cvmfs/neurodesk.ardc.edu.au/containers/${IMAGENAME_BUILDDATE}/${IMAGENAME_BUILDDATE}.simg/.singularity.d/env/99-zz_custom_env.sh" ]]
    # then
    #     echo "99-zz_custom_env exists for ${IMAGENAME_BUILDDATE} on cvmfs"
    # else
    #     echo "99-zz_custom_env does not exist for ${IMAGENAME_BUILDDATE} on cvmfs. Creating it."
    #     CUSTOM_ENV=/.singularity.d/env/99-zz_custom_env.sh
    #     echo "#!/bin/bash" >> $CUSTOM_ENV
    #     PS1="[my_container]\w \$"
    #     EOF
    #         chmod 755 $CUSTOM_ENV
    # fi

    # set internal field separator for the string list
    echo $CATEGORIES
    IFS=','
    for CATEGORY in $CATEGORIES;
    do
        echo $CATEGORY
        CATEGORY="${CATEGORY// /_}"

        if [[ -a "/cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/$CATEGORY/$TOOLNAME/$TOOLVERSION" ]]
        then
            echo "$IMAGENAME_BUILDDATE exists in module $CATEGORY"
            echo "Checking if files are up-to-date:"
            FILE1=/cvmfs/neurodesk.ardc.edu.au/containers/modules/$TOOLNAME/$TOOLVERSION
            FILE2=/cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/$CATEGORY/$TOOLNAME/$TOOLVERSION
            if cmp --silent -- "$FILE1" "$FILE2"; then
                echo "files contents are identical"
            else
                echo "files differ - copy again:"
                cvmfs_server transaction neurodesk.ardc.edu.au
                cp /cvmfs/neurodesk.ardc.edu.au/containers/modules/$TOOLNAME/$TOOLVERSION /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/$CATEGORY/$TOOLNAME/$TOOLVERSION
                cd && cvmfs_server publish -m "updating modules for $IMAGENAME_BUILDDATE" neurodesk.ardc.edu.au
            fi
        else
            cvmfs_server transaction neurodesk.ardc.edu.au
            mkdir -p /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/$CATEGORY/$TOOLNAME/
            cp /cvmfs/neurodesk.ardc.edu.au/containers/modules/$TOOLNAME/$TOOLVERSION /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/$CATEGORY/$TOOLNAME/$TOOLVERSION
            cd && cvmfs_server publish -m "added modules for $IMAGENAME_BUILDDATE" neurodesk.ardc.edu.au
            if  [[ -f /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/$CATEGORY/$TOOLNAME/$TOOLVERSION ]]; then
                echo "module file $CATEGORY/$TOOLNAME/$TOOLVERSION written. This worked!"
            else
                echo "Something went wrong: cp /cvmfs/neurodesk.ardc.edu.au/containers/modules/$TOOLNAME/$TOOLVERSION /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/$CATEGORY/$TOOLNAME/$TOOLVERSION"
                exit 2
            fi
        fi
    done
    
    IFS=$Field_Separator

done < /home/ec2-user/neurocommand/cvmfs/log.txt

rm -rf $LOCKFILE
cp ~/cronjob.log ~/cronjob_previous_run.log
rm ~/cronjob.log

# check if catalog is OK:
# cvmfs_server list-catalogs -e


# garbage collection:
# sudo cvmfs_server gc neurodesk.ardc.edu.au

# Display tags
# cvmfs_server tag -l
