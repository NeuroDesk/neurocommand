This project aims at deploying a singularity container transparently, so that an application inside the container can be used without adjusting any scripts or pipelines (e.g. nipype). For building your own containers see examples in https://github.com/CAIsr/caid  

## Important: add bind points to .bashrc before executing this script
This script expects that you have adjusted the Singularity Bindpoints in your .bashrc, e.g.:
```
export SINGULARITY_BINDPATH="/gpfs1/,/QRISdata,/data"
```

## This gives you a list of available images:
```
curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages
```

## clone repo into a folder with the intented image name
```
git clone https://github.com/CAIsr/transparent-singularity.git minc_1p9p16_visual_20181022.simg	
```

## install
this will create scripts for every binary in the container located in the $DEPLOY_PATH inside the container. It will also create activate and deactivate scripts and module files for lmod (https://lmod.readthedocs.io/en/latest/)
```
cd minc_1p9p16_visual_20181022.simg
./run_transparent_singularity.sh minc_1p9p16_visual_20181022.simg
```

# Use in module system LMOD
add the module folder path to $MODULEPATH

# Manual acivation and deactivation (in case module system is not available). This will add the paths to the .bashrc
## activate
```
source activate_minc_1p9p16_visual_20181022.simg.sh
```

## deactivate
```
source deactivate_minc_1p9p16_visual_20181022.simg.sh
```


## cleanup
```
./ts_cleanupCommands.sh
rm activate_minc_1p9p16_visual_20181022.simg.sh
rm deactivate_minc_1p9p16_visual_20181022.simg.sh
rm commands.txt
```
## updating a container the quick and easy way:
list and pick name: 
curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages

get:
curl -v -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/insertCONTAINERname -O
