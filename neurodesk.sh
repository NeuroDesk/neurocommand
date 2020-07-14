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

# Build the menu
cd ${installdir}/menus
python3 build_menu.py

if [ "$lxde_system_install" = "true" ]; then
    echo "doing lxde_system_install replacing system files!"

    # Main-menu config. Add Menu changes to lxde-applications.menu
    # sed '/PATTERN/ a <LINE-TO-BE-ADDED>' FILE.txt
    sed '/DefaultMergeDirs/ a <MergeFile>vnm-applications.menu</MergeFile>' /etc/xdg/menus/lxde-applications.menu > ${installdir}/menus/lxde-applications.menu
    rm /etc/xdg/menus/lxde-applications.menu
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

