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
echo "lxde_system_install: $lxde_system_install"

# Build the menu
cd ${installdir}/menus
python3 build_menu.py


if [ "$lxde_system_install" = "true" ]; then
    echo "replacing system files!"
    mkdir -p /root/.config/lxpanel/LXDE/icons
    ln -s ${installdir}/menus/icons/* /root/.config/lxpanel/LXDE/icons/
    chmod 644 /root/.config/lxpanel/LXDE/icons/*

    # Main-menu config. Add Menu changes to lxde-applications.menu
    # sed '/PATTERN/ a <LINE-TO-BE-ADDED>' FILE.txt
    cp /etc/xdg/menus/lxde-applications.menu /etc/xdg/menus/lxde-applications.menu2
    sed '/DefaultMergeDirs/ a <MergeFile>vnm-applications.menu</MergeFile>' /etc/xdg/menus/lxde-applications.menu2 > /etc/xdg/menus/lxde-applications.menu
    rm /etc/xdg/menus/lxde-applications.menu2

    ln -s ${installdir}/menus/vnm-applications.menu /etc/xdg/menus/

    chmod 644 /etc/xdg/menus/lxde-applications.menu

    ln -s ${installdir}/menus/vnm-neuroimaging.directory /usr/share/desktop-directories/
    ln -s ${installdir}/fetch_and_run.sh /usr/share/
    ln -s ${installdir}/menus/desktop-directories/* /usr/share/desktop-directories/
    ln -s ${installdir}/menus/applications/* /usr/share/applications
fi

