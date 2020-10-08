#!/bin/bash

source neurodesk/configparser.sh

echo "WARNING: Will modify/replace system files!!!"
read -p "Press enter to continue ..."
rm_symlink ${vnm[appmenu]}
rm_symlink $appmenudir/vnm-applications.menu

if [ -n "${vnm[appmenu]}" ]; then
mv -vn ${vnm[appmenu]}.BAK ${vnm[appmenu]}
fi
for file in ${vnm[appdir]}/vnm-*.desktop; do
    rm_symlink $file
done
for file in ${vnm[deskdir]}/vnm-*.directory; do
    rm_symlink $file
done
