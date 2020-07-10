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

if [ "$lxde_system_install" = "true" ]; then
    echo "replacing system files!"
    mkdir -p /root/.config/lxpanel/LXDE/icons
    ln -s ${installdir}/menus/icons/* /root/.config/lxpanel/LXDE/icons/
    chmod 644 /root/.config/lxpanel/LXDE/icons/*

    # Main-menu config. Add Menu changes to vnm-applications.menu
    # sed '/PATTERN/ a <LINE-TO-BE-ADDED>' FILE.txt
    sed '/DefaultMergeDirs/ a <MergeFile>vnm-applications.menu</MergeFile>' /etc/xdg/menus/lxde-applications.menu

    ln -s ${installdir}/menus/vnm-applications.menu /etc/xdg/menus/

    chmod 644 /etc/xdg/menus/lxde-applications.menu

    ln -s ${installdir}/menus/vnm-neuroimaging.directory /usr/share/desktop-directories/
    ln -s ${installdir}/fetch_and_run.sh /usr/share/

    # Build the menu
    cd ${installdir}/menus
    python3 build_menu.py
fi