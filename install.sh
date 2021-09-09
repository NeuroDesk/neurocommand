#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
source neurodesk/configparser.sh ${_base}/config.ini

echo "WARNING: Will modify/replace system files!!!"
# read -p "Press enter to continue ..."

if [ "${neurodesk_edit}" == "y" ]; then
    mv -vn ${neurodesk_appmenu} ${neurodesk_appmenu}.BAK    
    ln -sfn ${neurodesk_installdir}/${neurodesk_appmenufile} ${neurodesk_appmenudir}
else 
    echo "!!! Add <MergeFile>neurodesk-applications.menu</MergeFile> to ${neurodesk_appmenu} !!!"
fi
ln -sfn ${neurodesk_installdir}/neurodesk-applications.menu ${neurodesk_appmenudir}

ln -sfn ${neurodesk_installdir}/applications ${neurodesk_appdir}/neurodesk
ln -sfn ${neurodesk_installdir}/desktop-directories ${neurodesk_deskdir}/neurodesk

#for file in ${neurodesk_installdir}/applications/vnm-*.desktop; do
#    ln -s $file ${neurodesk_appdir}
#done
#for file in ${neurodesk_installdir}/desktop-directories/vnm-*.directory; do
#    ln -s $file ${neurodesk_deskdir}
#done
