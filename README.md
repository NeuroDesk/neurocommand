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
./run_transparent_singularity.sh tgvqsm_20180730_intel.simg
```
this will add everything you need to your .bashrc. Source .bashrc to get everything setup.


## deactivate
```
source deactivate_fsl_5p0p11_20180712.simg.sh
```

## activate
```
source activate_fsl_5p0p11_20180712.simg.sh
```

## cleanup
```
./ts_cleanupCommands.sh
rm activate_fsl_5p0p11_20180712.simg.sh
rm deactivate_fsl_5p0p11_20180712.simg.sh
rm commands.txt
```
