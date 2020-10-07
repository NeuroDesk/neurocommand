#!/bin/bash

source utils/configparser.sh

echo "WARNING: Will modify/replace system files!!!"
read -p "Press enter to continue ..."
mv -vn ${vnm[appmenu]} ${vnm[appmenu]}.BAK
ln -s ${vnm[installdir]}/$appmenufile $appmenudir
ln -s ${vnm[installdir]}/vnm-applications.menu $appmenudir

for file in ${vnm[installdir]}/applications/vnm-*.desktop; do
    ln -s $file ${vnm[appdir]}
done
for file in ${vnm[installdir]}/desktop-directories/vnm-*.directory; do
    ln -s $file ${vnm[deskdir]}
done
