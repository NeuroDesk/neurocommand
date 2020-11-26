#!/bin/bash

source neurodesk/configparser.sh

install_all_containers="false"

if [ "$1" != "" ]; then
    echo "Installing all containers"
    install_all_containers="true"
fi

# wget -c https://github.com/NeuroDesk/transparent-singularity/archive/master.zip -O ${vnm_installdir}/transparent-singularity.zip
# unzip -o ${vnm_installdir}/transparent-singularity.zip -d ${vnm_installdir}

cat ${vnm_installdir}/bin/vnm-* | grep fetch_and_run > all_execs.sh

sed -i 's/Exec=//g' all_execs.sh
sed -i 's/fetch_and_run.sh/fetch_containers.sh/g' all_execs.sh
sed -i 's/export LD_PRELOAD=""; module load singularity; //g' all_execs.sh

if [ "$install_all_containers" = "true" ]; then
    echo "================================"
    echo "downloading all containers now!"
    echo "================================"
    while IFS="" read -r p || [ -n "$p" ]
    do
    date
    echo "executing " $p
    if $p ; then
        echo "Container successfully installed"
        echo "-------------------------------------------------------------------------------------"
        date
    else
        echo "======================================="
        echo "!!!!!!! Container install failed !!!!!!"
        echo "======================================="
        date
        exit
    fi
    done < all_execs.sh
fi

echo "------------------------------------"
echo "to install individual containers, run:"
cat all_execs.sh


echo "------------------------------------"
echo "to install ALL containers, run:"
echo "bash containers.sh --all"
