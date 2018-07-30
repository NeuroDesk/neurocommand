This project aims at deploying a singularity container transparently, so that an application inside the container can be used without adjusting any scripts or pipelines (e.g. nipype) 

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
git clone git@gitlab.com:uqsbollm/transparent_singularity tgvqsm_intel_20180730.simg	
```

## install
```
cd tgvqsm_intel_20180730.simg
./run_transparent_singularity.sh tgvqsm_intel_20180730.simg
```
this will add everything you need to your .bashrc. Source .bashrc to get everything setup.


## deactivate
```
source deactivate_tgvqsm_intel_20180730.simg.sh
```

## activate
```
source activate_tgvqsm_intel_20180730.simg.sh
```

## cleanup
```
./ts_cleanupCommands.sh
rm activate_tgvqsm_intel_20180730.simg.sh
rm deactivate_tgvqsm_intel_20180730.simg.sh
rm commands.txt
```
