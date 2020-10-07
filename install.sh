#!/bin/bash

source utils/configparser.sh

filename="config.ini"
section="vnm"
GetINISection "$filename" "$section"

appmenudir="$(dirname "${vnm[appmenu]}")"

echo "WARNING: Will modify/replace system files!!!"
read -p "Press enter to continue ..."
mv -vn ${vnm[appmenu]} ${vnm[appmenu]}.BAK
ln -s ${vnm[installdir]}/lxde-applications.menu $appmenudir
ln -s ${vnm[installdir]}/vnm-applications.menu $appmenudir

for file in ${vnm[installdir]}/desktop-directories/vnm-*.directory; do
    ln $file ${vnm[deskdir]}
done
for file in ${vnm[installdir]}/desktop-directories/vnm-*.desktop; do
    ln $file ${vnm[appdir]}
done
