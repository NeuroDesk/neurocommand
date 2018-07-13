This repo aims at deploing a singularity containers transparently on our clusters.

## clone repo
git clone git@gitlab.com:uqsbollm/deploy_containers.git

## rename to image name
mv deploy_containers fsl_5p0p11
cd fsl_5p0p11

## edit which image should be installed
vi run_deploy_container.sh

## install
source run_deploy_container.sh

## deactivate
source deactivate_fsl_5p0p11_20180712.simg.sh

## activate
source activate_fsl_5p0p11_20180712.simg.sh

## cleanup
./dc_cleanupCommands.sh
rm activate_fsl_5p0p11_20180712.simg.sh
rm deactivate_fsl_5p0p11_20180712.simg.sh
rm commands.txt

