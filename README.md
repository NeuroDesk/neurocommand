This repo aims at deploing a singularity containers transparently on our clusters.

## This gives you a list of available images:
```
curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages
```

## clone repo into a folder with the intented image name
```
git clone git@gitlab.com:uqsbollm/transparent_singularity tgvqsm_20180730_intel
```

## install
```
cd tgvqsm_20180730_intel
./run_transparent_singularity.sh tgvqsm_20180730_intel.simg
```
this will add everything you need to your .bashrc. Source .bashrc to get everything setup.


## deactivate
```
source deactivate_tgvqsm_20180730_intel.simg.sh
```

## activate
```
source activate_tgvqsm_20180730_intel.simg.sh
```

## cleanup
```
./ts_cleanupCommands.sh
rm activate_tgvqsm_20180730_intel.simg.sh
rm deactivate_tgvqsm_20180730_intel.simg.sh
rm commands.txt
```
