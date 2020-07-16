#!/usr/bin/env bash
set -e

#cleanup swift storage first
curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages

echo Enter container filename to be deleted on SWIFT storage:
read containerName

source ../setupSwift.sh

echo "deleting ..."
swift delete singularityImages ${containerName}


cd menus
rm log.txt
python write_log.py
cd ..

sed -i '/^$/d' menus/log.txt

while read p; do
  name=`echo "$p" | cut -d ' ' -f 2`
  echo $name
  version=`echo "$p" | cut -d ' ' -f 3`
  echo $version
  buildDate=`echo "$p" | cut -d ' ' -f 4`
  echo $buildDate

  if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${name}_${version}_${buildDate}.sif"; then
    echo "${name}_${version}_${buildDate}.sif exists"
  else
    echo "${name}_${version}_${buildDate}.sif does not exist yet - caching from docker and storing on swift!"
    singularity pull docker://vnmd/${name}_${version}:${buildDate}
    source ../setupSwift.sh
    swift upload singularityImages ${name}_${version}_${buildDate}.sif --segment-size 1073741824
    rm ${name}_${version}_${buildDate}.sif
  fi
done <menus/log.txt


#tagging release
export buildDate=`date +%Y%m%d`
echo "tagging this release as ${buildDate}"
git tag buildDate
git push origin --tags

