#!/bin/bash
set -e

POSITIONAL=()
while [[ $# -gt 0 ]]
   do
   key="$1"

   case $key in
      -d|--installdir)
      installdir="$2"
      shift # past argument
      shift # past value
      ;;
      -lxde|--lxde_system_install)
      lxde_system_install="$2"
      shift # past argument
      shift # past value
      ;;
      -all|--install_all_containers)
      install_all_containers="$2"
      shift # past argument
      shift # past value
      ;;
      --default)
      DEFAULT=YES
      shift # past argument
      ;;
      *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
   esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z "$installdir" ]; then
    installdir=`pwd -P`
fi

echo "installdir: $installdir"

# Build the menu
cd ${installdir}/menus

# start fresh from template:
cp vnm-applications.menu.template vnm-applications.menu
[ -d applications/vnm ] && rm applications/vnm/vnm-*
[ -d desktop-directories/vnm ] && rm desktop-directories/vnm/vnm-*

python3 build_menu.py

sed "/Comment/ a Icon=${installdir}/menus/icons/vnm.png" ${installdir}/menus/vnm-neuroimaging.directory > ${installdir}/menus/desktop-directories/vnm/vnm-neuroimaging.directory



if [ "$lxde_system_install" = "true" ]; then
    echo "doing lxde_system_install replacing system files!"

    # Main-menu config. Add Menu changes to lxde-applications.menu
    # sed '/PATTERN/ a <app-TO-BE-ADDED>' FILE.txt
    sed '/DefaultMergeDirs/ a <MergeFile>vnm-applications.menu</MergeFile>' /etc/xdg/menus/lxde-applications.menu > ${installdir}/menus/lxde-applications.menu
    # Backup lxde-applications.menu
    mv /etc/xdg/menus/lxde-applications.menu /etc/xdg/menus/lxde-applications.menu.BAK
    ln -s ${installdir}/menus/lxde-applications.menu /etc/xdg/menus/
    chmod 644 /etc/xdg/menus/lxde-applications.menu

    ln -s ${installdir}/menus/vnm-applications.menu /etc/xdg/menus/
    chmod 644 /etc/xdg/menus/vnm-applications.menu

    if [ -d /usr/share/desktop-directories/ ]
    then
        cp /usr/share/desktop-directories/* ${installdir}/menus/desktop-directories/
        rm -rf /usr/share/desktop-directories/
    fi
    ln -s ${installdir}/menus/desktop-directories/ /usr/share/

    if [ -d /usr/share/applications/ ]
    then
        cp /usr/share/applications/* ${installdir}/menus/applications/
        rm -rf /usr/share/applications/
    fi
    ln -s ${installdir}/menus/applications/ /usr/share/applications
fi


cat ${installdir}/menus/applications/vnm/vnm-* | grep Exec > all_execs.sh
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