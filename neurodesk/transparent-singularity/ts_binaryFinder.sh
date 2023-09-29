#!/usr/bin/env bash
IFS=':'; \
for i in $DEPLOY_PATH; \
   do find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; 
   find "$i" -maxdepth 1 -executable -type l -exec basename {} \;;
   done > commands_raw.txt

for i in $DEPLOY_BINS; \
   do echo "$i"; done >> commands_raw.txt

# if $DEBUG
#    export DEPLOY_ENV_FSLDIR="BASEPATH/opt/fsl-5.0.2"
#    export DEPLOY_ENV_SPMMCRCMD="BASEPATH/opt/spm12/run_spm12.sh BASEPATH/opt/mcr/v97/ script"
# fi


# Find system applications in Neurodesktop:
# IFS=':'; \
# for i in $PATH; \
#    do find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done > system_commands_raw.txt

# Find binaries in FSL image:
# comm -12 <( sort commands_raw.txt ) <( sort system_commands_raw.txt ) > overlap.txt


# Remove system applications from commands.txt, because they cause problems:
# THIS CURRENTLY DOESNT WORK. It also removes commands that have system commands as subsets. E.g. dicom-sort will be removed because it contains sort.
# getListOfSystemCommandsToBeDeleted() {
#   printf '%s\n' `cat ts_binaryFinderExcludes.txt`
# }

# sed -E 's/\<('"$(tr '\n' '|' < <(getListOfSystemCommandsToBeDeleted) )"')\>//gI' < commands_raw.txt > commands.txt
# sed -i '/^\s*$/d' commands.txt

# This is a temporary fix:
cp commands_raw.txt commands.txt

touch env.txt
env | grep DEPLOY_ENV_ > env.txt

