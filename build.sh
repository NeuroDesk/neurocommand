#!/bin/bash
# python -m neurodesk $@

set -e

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##

source ${_base}/neurodesk/configparser.sh ${_base}/config.ini

args=""

# Arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
   do
   key="$1"

   case $key in
      --init)
      init=true
      shift # past argument
      ;;
      --edit)
      edit=true
      shift # past argument
      ;;
      --lxde)
      lxde=true
      shift # past argument
      ;;
      --cli)
      cli=true
      shift # past argument
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

if [ "$lxde" = true ]; then
    vnm_deskenv=lxde
    vnm_installdir="$(pwd -P)/local"
    vnm_appmenu=/etc/xdg/menus/lxde-applications.menu
    vnm_appdir=/usr/share/applications/
    vnm_deskdir=/usr/share/desktop-directories/
    vnm_edit=n
    echo "deskenv> lxde preset" 
    echo
fi

if [ "$edit" = true ]; then
    vnm_edit=y
    echo "edit> Yes" 
    echo
fi

if [ "$cli" = true ]; then
    vnm_deskenv=cli
    vnm_installdir="$(pwd -P)/local"
    echo "deskenv> cli preset" 
    echo
fi

if [ "$init" = true ]; then
    # Installation Directory [./local]
    echo "Enter Installation Directory. Blank for default [./local]"
    read -e -p "installdir> " vnm_installdir
    vnm_installdir="${vnm_installdir/#\~/$HOME}"
    if [ -z "$vnm_installdir" ]; then
        vnm_installdir="$(pwd -P)"
    fi
    if [ ! -d "$vnm_installdir" ]; then
        echo "Installation directory does not exist"
        echo "Creating $vnm_installdir"
        mkdir -p $vnm_installdir
    fi
    vnm_installdir=$(readlink -f ${vnm_installdir})
    if [ "$vnm_installdir" == $(pwd -P) ]; then
        vnm_installdir="$(pwd -P)/local"
        mkdir -p $vnm_installdir
    fi
    echo "Installation directory at $vnm_installdir"
    echo 

    # Desktop Environment [cli/lxde/mate]
    echo "Enter Desktop Environment [cli/lxde/mate]"
    read -p "deskenv> " vnm_deskenv
    vnm_deskenv=$(echo "$vnm_deskenv" | tr '[:upper:]' '[:lower:]')
    case "$vnm_deskenv" in
      cli|lxde|mate)
        echo "Environment set to $vnm_deskenv"
        ;;
      *)
        echo "Defaulting to cli environment"
        vnm_deskenv="cli"
        ;;
    esac
    echo

    if [ $vnm_deskenv != "cli" ]; then
        # Applications Menu
        read -e -p "appmenu: " vnm_appmenu
        vnm_appmenu=$(resolve_abs_path $vnm_appmenu)
        echo "Applications Menu at $vnm_appmenu"
        echo 

        # Applications Directory
        read -e -p "appdir: " vnm_appdir
        vnm_appdir=$(resolve_abs_path $vnm_appdir)
        echo "Installation directory at $vnm_installdir"
        echo 

        # Desktop Directories
        read -e -p "deskdir: " vnm_deskdir
        vnm_deskdir=$(resolve_abs_path $vnm_deskdir)
        echo "Installation directory at $vnm_installdir"
        echo 

        # vnm_edit mode [y/n]
        read -p "edit : " vnm_edit
        case "$vnm_edit" in
        y/n)
            echo "edit set to $vnm_edit"
            ;;
        *)
            echo "Defaulting to no edit"
            vnm_edit="n"
            ;;
        esac

    fi
fi

args="${args} --installdir=$vnm_installdir"
args="${args} --deskenv=$vnm_deskenv"
mkdir -p $vnm_installdir

if [ $vnm_deskenv != "cli" ]; then
    # Test Applications Menu
    echo "Checking appmenu> $vnm_appmenu"
    validfile=false
    if [ ! -f "$vnm_appmenu" ]; then
        echo "Applications Menu not found"
        exit 1
    fi
    mkdir -p $vnm_installdir/desktop-directories
    mkdir -p $vnm_installdir/icons
    cp $vnm_appmenu $vnm_installdir/local-applications.menu.template
    cp neurodesk/icons/*.png $vnm_installdir/icons

    # Test Applications Directory
    echo "Checking appdir> $vnm_appdir"
    validfile=false
    for i in $vnm_appdir/*.desktop; do
        if [[ -e $i ]]; then
            echo " - contains *.desktop file(s)"
            validfile=true
            break
        fi
    done
    if [ "$validfile" = false ]; then
        echo " - missing *.desktop file(s)"
        echo "Invalid Applications Directory"
        exit 1
    fi
    echo

    # Test Desktop Directory
    echo "Checking deskdir> $vnm_deskdir"
    validfile=false
    for i in $vnm_deskdir/*.directory; do
        if [[ -e $i ]]; then
            echo " - contains *.directory file(s)"
            validfile=true
            break
        fi
    done
    if [ "$validfile" = false ]; then
        echo " - missing *.directory file(s)"
        echo "Invalid Desktop Directory"
        exit 1
    fi
    echo

    args="${args} --appmenu=$vnm_appmenu"
    args="${args} --appdir=$vnm_appdir"
    args="${args} --deskdir=$vnm_deskdir"
    args="${args} --edit=$vnm_edit"
fi

python3 -m neurodesk $args
