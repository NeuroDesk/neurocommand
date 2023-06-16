#!/usr/bin/env bash
IFS=':'; \
for i in $DEPLOY_PATH; \
   do find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done > commands_raw.txt

for i in $DEPLOY_BINS; \
   do echo "$i"; done >> commands_raw.txt

# if $DEBUG
#    export DEPLOY_ENV_FSLDIR="BASEPATH/opt/fsl-5.0.2"
#    export DEPLOY_ENV_SPMMCRCMD="BASEPATH/opt/spm12/run_spm12.sh BASEPATH/opt/mcr/v97/ script"
# fi


# Remove system applications from commands.txt, because they cause problems:
getListOfSystemCommandsToBeDeleted() {
  printf '%s\n' conda bash cat chmod cp cut date echo env find grep head ln ls mkdir mv pwd rm sed sort tail touch tr uname uniq wc
}

sed -E 's/\<('"$(tr '\n' '|' < <(getListOfSystemCommandsToBeDeleted) )"')\>//gI' < commands_raw.txt > commands.txt
sed -i '/^\s*$/d' commands.txt

touch env.txt
env | grep DEPLOY_ENV_ > env.txt

