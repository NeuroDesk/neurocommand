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
    deskenv=lxde
    installdir="$(pwd -P)/local"
    appmenu=/etc/xdg/menus/lxde-applications.menu
    appdir=/usr/share/applications/
    deskdir=/usr/share/desktop-directories/
    edit=y
    echo "deskenv> lxde preset" 
    echo
fi

if [ "$edit" = true ]; then
    edit=y
    echo "edit> Yes" 
    echo
fi

if [ "$cli" = true ]; then
    deskenv=cli
    installdir="$(pwd -P)/local"
    echo "deskenv> cli preset" 
    echo
fi

if [ "$init" = true ]; then
    # Installation Directory [./local]
    echo "Enter Installation Directory. Blank for default [./local]"
    read -e -p "installdir> " installdir
    installdir="${installdir/#\~/$HOME}"
    if [ -z "$installdir" ]; then
        installdir="$(pwd -P)"
    fi
    if [ ! -d "$installdir" ]; then
        echo "Installation directory does not exist"
        echo "Creating $installdir"
        mkdir -p $installdir
    fi
    installdir=$(readlink -f ${installdir})
    if [ "$installdir" == $(pwd -P) ]; then
        installdir="$(pwd -P)/local"
        mkdir -p $installdir
    fi
    echo "Installation directory at $installdir"
    echo 

    # Desktop Environment [cli/lxde/mate]
    echo "Enter Desktop Environment [cli/lxde/mate]"
    read -p "deskenv> " deskenv
    deskenv=$(echo "$deskenv" | tr '[:upper:]' '[:lower:]')
    case "$deskenv" in
      cli|lxde|mate)
        echo "Environment set to $deskenv"
        ;;
      *)
        echo "Defaulting to cli environment"
        deskenv="cli"
        ;;
    esac
    echo

    if [ $deskenv != "cli" ]; then
        # Applications Menu
        read -e -p "appmenu: " appmenu
        appmenu=$(resolve_abs_path $appmenu)
        echo "Applications Menu at $appmenu"
        echo 

        # Applications Directory
        read -e -p "appdir: " appdir
        appdir=$(resolve_abs_path $appdir)
        echo "Installation directory at $installdir"
        echo 

        # Desktop Directories
        read -e -p "deskdir: " deskdir
        deskdir=$(resolve_abs_path $deskdir)
        echo "Installation directory at $installdir"
        echo 

        # Edit mode [y/n]
        read -p "edit : " edit
        case "$edit" in
        y/n)
            echo "Edit set to $edit"
            ;;
        *)
            echo "Defaulting to no edit"
            edit="n"
            ;;
        esac

    fi
fi

args="${args} --installdir=$installdir"
args="${args} --deskenv=$deskenv"
mkdir -p $installdir

if [ $deskenv != "cli" ]; then
    # Test Applications Menu
    echo "Checking appmenu> $appmenu"
    validfile=false
    if [ ! -f "$appmenu" ]; then
        echo "Applications Menu not found"
        exit 1
    fi
    mkdir -p $installdir/desktop-directories
    mkdir -p $installdir/icons
    cp $appmenu $installdir/local-applications.menu.template
    cp neurodesk/icons/*.png $installdir/icons

    # Test Applications Directory
    echo "Checking appdir> $appdir"
    validfile=false
    for i in $appdir/*.desktop; do
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
    echo "Checking deskdir> $deskdir"
    validfile=false
    for i in $deskdir/*.directory; do
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

    args="${args} --appmenu=$appmenu"
    args="${args} --appdir=$appdir"
    args="${args} --deskdir=$deskdir"
    args="${args} --edit=$edit"
fi

python -m neurodesk $args
