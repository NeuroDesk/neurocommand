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
    neurodesk_deskenv=lxde
    neurodesk_installdir="$(pwd -P)/local"
    neurodesk_appmenu=/etc/xdg/menus/lxde-applications.menu
    neurodesk_appdir=/usr/share/applications/
    neurodesk_deskdir=/usr/share/desktop-directories/
    neurodesk_edit=n
    echo "deskenv> lxde preset" 
    echo
fi

if [ "$edit" = true ]; then
    neurodesk_edit=y
    echo "edit> Yes" 
    echo
fi

if [ "$cli" = true ]; then
    neurodesk_deskenv=cli
    neurodesk_installdir="$(pwd -P)/local"
    echo "deskenv> cli preset" 
    echo
fi

if [ "$init" = true ]; then
    # Installation Directory [./local]
    echo "Enter Installation Directory. Blank for default [./local]"
    read -e -p "installdir> " neurodesk_installdir
    neurodesk_installdir="${neurodesk_installdir/#\~/$HOME}"
    if [ -z "$neurodesk_installdir" ]; then
        neurodesk_installdir="$(pwd -P)"
    fi
    if [ ! -d "$neurodesk_installdir" ]; then
        echo "Installation directory does not exist"
        echo "Creating $neurodesk_installdir"
        mkdir -p $neurodesk_installdir
    fi
    neurodesk_installdir=$(readlink -f ${neurodesk_installdir})
    if [ "$neurodesk_installdir" == $(pwd -P) ]; then
        neurodesk_installdir="$(pwd -P)/local"
        mkdir -p $neurodesk_installdir
    fi
    echo "Installation directory at $neurodesk_installdir"
    echo 

    # Desktop Environment [cli/lxde/mate]
    echo "Enter Desktop Environment [cli/lxde/mate]"
    read -p "deskenv> " neurodesk_deskenv
    neurodesk_deskenv=$(echo "$neurodesk_deskenv" | tr '[:upper:]' '[:lower:]')
    case "$neurodesk_deskenv" in
      cli|lxde|mate)
        echo "Environment set to $neurodesk_deskenv"
        ;;
      *)
        echo "Defaulting to cli environment"
        neurodesk_deskenv="cli"
        ;;
    esac
    echo

    if [ $neurodesk_deskenv != "cli" ]; then
        # Applications Menu
        read -e -p "appmenu: " neurodesk_appmenu
        neurodesk_appmenu=$(resolve_abs_path $neurodesk_appmenu)
        echo "Applications Menu at $neurodesk_appmenu"
        echo 

        # Applications Directory
        read -e -p "appdir: " neurodesk_appdir
        neurodesk_appdir=$(resolve_abs_path $neurodesk_appdir)
        echo "Installation directory at $neurodesk_installdir"
        echo 

        # Desktop Directories
        read -e -p "deskdir: " neurodesk_deskdir
        neurodesk_deskdir=$(resolve_abs_path $neurodesk_deskdir)
        echo "Installation directory at $neurodesk_installdir"
        echo 

        # neurodesk_edit mode [y/n]
        read -p "edit : " neurodesk_edit
        case "$neurodesk_edit" in
        y/n)
            echo "edit set to $neurodesk_edit"
            ;;
        *)
            echo "Defaulting to no edit"
            neurodesk_edit="n"
            ;;
        esac

    fi
fi

args="${args} --installdir=$neurodesk_installdir"
args="${args} --deskenv=$neurodesk_deskenv"
mkdir -p $neurodesk_installdir

if [ $neurodesk_deskenv != "cli" ]; then
    # Test Applications Menu
    echo "Checking appmenu> $neurodesk_appmenu"
    validfile=false
    if [ ! -f "$neurodesk_appmenu" ]; then
        echo "Applications Menu not found"
        exit 1
    fi
    mkdir -p $neurodesk_installdir/desktop-directories
    mkdir -p $neurodesk_installdir/icons
    cp $neurodesk_appmenu $neurodesk_installdir/local-applications.menu.template
    cp neurodesk/icons/*.png $neurodesk_installdir/icons

    # Test Applications Directory
    echo "Checking appdir> $neurodesk_appdir"
    validfile=false
    for i in $neurodesk_appdir/*.desktop; do
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
    echo "Checking deskdir> $neurodesk_deskdir"
    validfile=false
    for i in $neurodesk_deskdir/*.directory; do
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

    args="${args} --appmenu=$neurodesk_appmenu"
    args="${args} --appdir=$neurodesk_appdir"
    args="${args} --deskdir=$neurodesk_deskdir"
    args="${args} --edit=$neurodesk_edit"
fi

python3 -m neurodesk $args
