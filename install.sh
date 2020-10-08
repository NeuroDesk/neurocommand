#!/bin/bash

source neurodesk/configparser.sh

echo "WARNING: Will modify/replace system files!!!"
read -p "Press enter to continue ..."
if [ "${vnm[edit]}" == "y" ]; then
    mv -vn ${vnm[appmenu]} ${vnm[appmenu]}.BAK
    ln -s ${vnm[installdir]}/$appmenufile $appmenudir
else 
    echo "!!! Add <MergeFile>vnm-applications.menu</MergeFile> to ${vnm[appmenu]} !!!"
fi
ln -s ${vnm[installdir]}/vnm-applications.menu $appmenudir

for file in ${vnm[installdir]}/applications/vnm-*.desktop; do
    ln -s $file ${vnm[appdir]}
done
for file in ${vnm[installdir]}/desktop-directories/vnm-*.directory; do
    ln -s $file ${vnm[deskdir]}
done
