#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
source neurodesk/configparser.sh ${_base}/config.ini

rm_symlink(){ [ ! -L "$1" ] || rm -v "$1"; }

echo "WARNING: Will modify/replace system files!!!"
# read -p "Press enter to continue ..."

if [ "${vnm_edit}" == "y" ]; then
    rm_symlink ${vnm_appmenu}
    mv -vn ${vnm_appmenu}.BAK ${vnm_appmenu}
else 
    echo "!!! Remove <MergeFile>vnm-applications.menu</MergeFile> from ${vnm_appmenu} !!!"
fi
rm_symlink ${vnm_appmenudir}/vnm-applications.menu
rm_symlink ${vnm_appdir}/vnm
rm_symlink ${vnm_deskdir}/vnm

#for file in ${vnm_appdir}/vnm-*.desktop; do
#    rm_symlink $file
#done
#for file in ${vnm_deskdir}/vnm-*.directory; do
#    rm_symlink $file
#done
