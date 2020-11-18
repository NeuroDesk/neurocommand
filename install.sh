#!/bin/bash

source neurodesk/configparser.sh

echo "WARNING: Will modify/replace system files!!!"
# read -p "Press enter to continue ..."

if [ "${vnm_edit}" == "y" ]; then
    mv -vn ${vnm_appmenu} ${vnm_appmenu}.BAK    
    ln -sfn ${vnm_installdir}/${vnm_appmenufile} ${vnm_appmenudir}
else 
    echo "!!! Add <MergeFile>vnm-applications.menu</MergeFile> to ${vnm_appmenu} !!!"
fi
ln -sfn ${vnm_installdir}/vnm-applications.menu ${vnm_appmenudir}

ln -sfn ${vnm_installdir}/applications ${vnm_appdir}/vnm
ln -sfn ${vnm_installdir}/desktop-directories ${vnm_deskdir}/vnm

#for file in ${vnm_installdir}/applications/vnm-*.desktop; do
#    ln -s $file ${vnm_appdir}
#done
#for file in ${vnm_installdir}/desktop-directories/vnm-*.directory; do
#    ln -s $file ${vnm_deskdir}
#done
