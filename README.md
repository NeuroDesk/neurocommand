This repo aims at deploing a singularity containers transparently on our clusters.

## Important: add bind points to .bashrc
This script expects that you have adjusted the Singularity Bindpoints in your .bashrc:
```
export SINGULARITY_BINDPATH="/gpfs1/,/30days,/90days"
```

## This gives you a list of available images:
```
curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages
```

## clone repo into a folder with the intented image name
```
git clone git@gitlab.com:uqsbollm/transparent_singularity tgvqsm_intel_20180730	
```

## install
```
cd tgvqsm_intel_20180730
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
