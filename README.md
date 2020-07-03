This project allows to use singularity containers transparently on HPCs, so that an application inside the container can be used without adjusting any scripts or pipelines (e.g. nipype). 

## Important: add bind points to .bashrc before executing this script
This script expects that you have adjusted the Singularity Bindpoints in your .bashrc, e.g.:
```
export SINGULARITY_BINDPATH="/gpfs1/,/QRISdata,/data"
```

## This gives you a list of available images:
```
curl -s https://raw.githubusercontent.com/NeuroDesk/caid/master/Containerlist.md
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
source activate_minc_1p9p16_visual_20181022.simg.sh
```

## deactivate
```
source deactivate_minc_1p9p16_visual_20181022.simg.sh
```

## cleanup
```
./ts_cleanupCommands.sh
```
