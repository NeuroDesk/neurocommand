#!/bin/bash

source neurodesk/configparser.sh

echo "WARNING: Will modify/replace system files!!!"
read -p "Press enter to continue ..."

if [ "${vnm[edit]}" == "y" ]; then
    rm_symlink ${vnm[appmenu]}
    mv -vn ${vnm[appmenu]}.BAK ${vnm[appmenu]}
else 
    echo "!!! Remove <MergeFile>vnm-applications.menu</MergeFile> from ${vnm[appmenu]} !!!"
fi
rm_symlink $appmenudir/vnm-applications.menu
for file in ${vnm[appdir]}/vnm-*.desktop; do
    rm_symlink $file
done
for file in ${vnm[deskdir]}/vnm-*.directory; do
    rm_symlink $file
done
