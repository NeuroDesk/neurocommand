IFS=':'; \
for i in $DEPLOY_PATH; \
   do find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done > commands.txt

for i in $DEPLOY_BINS; \
   do echo "$i"; done >> commands.txt

# export DEPLOY_ENV_FSLDIR="BASEPATH/opt/fsl-5.0.2"
# export DEPLOY_ENV_SPMMCRCMD="BASEPATH/opt/spm12/run_spm12.sh BASEPATH/opt/mcr/v97/ script"

touch env.txt
env | grep DEPLOY_ENV_ > env.txt

