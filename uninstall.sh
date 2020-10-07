#!/bin/bash

source utils/configparser.sh

echo "WARNING: Will modify/replace system files!!!"
read -p "Press enter to continue ..."
rm_symlink ${vnm[appmenu]}
rm_symlink $appmenudir/vnm-applications.menu
mv -vn ${vnm[appmenu]}.BAK ${vnm[appmenu]}
for file in ${vnm[appdir]}/vnm-*.desktop; do
    rm_symlink $file
done
for file in ${vnm[deskdir]}/vnm-*.directory; do
    rm_symlink $file
done
