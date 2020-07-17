#!/usr/bin/env bash
# set -e

#tagging release
buildDate=`date +%Y%m%d`
echo "tagging this release as ${buildDate}"
# git tag -d ${buildDate}
# git push --delete origin ${buildDate}
git tag ${buildDate}
git push origin --tags

#creating logfile with available containers
cd menus
rm log.txt
python write_log.py
cd ..

sed -i '/^$/d' menus/log.txt




