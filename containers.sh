#!/bin/bash

source neurodesk/configparser.sh

install_all_containers="true"

cat ${vnm[installdir]}/applications/vnm-* | grep Exec > all_execs.sh
sed -i 's/Exec=//g' all_execs.sh
sed -i 's/fetch_and_run.sh/fetch_containers.sh/g' all_execs.sh

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
echo "to install all containers, run:"
echo "./neurodesk.sh --install_all_containers true"