This project allows to use singularity containers transparently on HPCs, so that an application inside the container can be used without adjusting any scripts or pipelines (e.g. nipype). 

## Important: add bind points to .bashrc before executing this script
This script expects that you have adjusted the Singularity Bindpoints in your .bashrc, e.g.:
```
export SINGULARITY_BINDPATH="/gpfs1/,/QRISdata,/data"
```

## This gives you a list of available images:
https://github.com/NeuroDesk/caid/packages
```
curl -s https://github.com/Neurodesk/caid/packages | sed -n "s/^.*\/NeuroDesk\/caid\/packages\/.*>\(.*\)\(\S*\)<\/a>$/\1/p"
```

## This gives you a list of all tested images available in neurodesk:
https://github.com/NeuroDesk/neurodesk/blob/master/menus/apps.json
```
curl -s https://raw.githubusercontent.com/NeuroDesk/neurodesk/master/menus/apps.json
```


## clone repo into a folder with the intented image name
```
git clone https://github.com/NeuroDesk/transparent-singularity convert3d_1.0.0_20200701
```

## install
this will create scripts for every binary in the container located in the $DEPLOY_PATH inside the container. It will also create activate and deactivate scripts and module files for lmod (https://lmod.readthedocs.io/en/latest/)
```
cd convert3d_1.0.0_20200701
./run_transparent_singularity.sh --container convert3d_1.0.0_20200701.sif
```

# Use in module system LMOD
add the module folder path to $MODULEPATH

# Manual activation and deactivation (in case module system is not available). This will add the paths to the .bashrc
## activate
```
source activate_convert3d_1.0.0_20200701.sif.sh
```

## deactivate
```
source deactivate_convert3d_1.0.0_20200701.sif.sh
```

## uninstall container and cleanup
```
./ts_uninstall.sh
```
