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
      -i|--system_install)
      system_install="$2"
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

# if there is only one argument use that as installdir
if [[ -n $1 ]]; then
    installdir="$1"
fi

if [ -z "$installdir" ]; then
    installdir=`pwd -P`
fi

echo "installing neurodesk in $installdir"

if [ "$system_install" = "true" ]; then
    echo "replacing system files!"
    mkdir -p /root/.config/lxpanel/LXDE/icons
    ln -s /neurodesk/menus/icons/* /root/.config/lxpanel/LXDE/icons/
    chmod 644 /root/.config/lxpanel/LXDE/icons/*

    # Main-menu config. Add Menu changes to vnm-applications.menu
    rm -rf /etc/xdg/menus/lxde-applications.menu
    mv /neurodesk/menus/lxde-applications.menu /etc/xdg/menus/
    # THIS SHOULD BE INSERTED via the neurodesk install script	<!-- VNM Applications submenu -->
        #<MergeFile>vnm-applications.menu</MergeFile>
    ln -s /neurodesk/menus/vnm-applications.menu /etc/xdg/menus/

    chmod 644 /etc/xdg/menus/lxde-applications.menu

    ln -s /neurodesk/menus/vnm-neuroimaging.directory /usr/share/desktop-directories/
    ln -s /neurodesk/fetch_and_run.sh /usr/share/

    # Build the menu
    cd /neurodesk/menus
    python3 build_menu.py
fi