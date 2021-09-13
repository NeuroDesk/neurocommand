#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
source neurodesk/configparser.sh ${_base}/config.ini

rm_symlink(){ [ ! -L "$1" ] || rm -v "$1"; }

echo "WARNING: Will modify/replace system files!!!"
# read -p "Press enter to continue ..."

if [ "${neurodesk_edit}" == "y" ]; then
    rm_symlink ${neurodesk_appmenu}
    mv -vn ${neurodesk_appmenu}.BAK ${neurodesk_appmenu}
else 
    echo "!!! Remove <MergeFile>neurodesk-applications.menu</MergeFile> from ${neurodesk_appmenu} !!!"
fi
rm_symlink ${neurodesk_appmenudir}/neurodesk-applications.menu
rm_symlink ${neurodesk_appdir}/neurodesk
rm_symlink ${neurodesk_deskdir}/neurodesk
