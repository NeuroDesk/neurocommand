#!/bin/bash
# python -m neurodesk $@

set -e

# Functions
resolve_abs_parentdir() {
    path="${1/#\~/$HOME}"
    parentdir=$(dirname "${path}")
    name=$(basename "${path}")
    echo "$(cd ${parentdir} && pwd -P)/${name}"
}
resolve_abs_path() {
    path="${1/#\~/$HOME}"
    name=$(basename "${path}")
    echo "$(cd ${path} && pwd -P)"
}

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
    appmenu=/etc/xdg/menus/lxde-applications.menu
    appdir=/usr/share/applications/
    deskdir=/usr/share/desktop-directories/
fi

if [ "$init" = true ]; then
    # Installation Directory [./local]
    echo "Enter Installation Directory. Blank for default [./local]"
    read -e -p "installdir> " installdir
    if [ -z "$installdir" ]; then
        installdir="$(pwd -P)"
    fi
    installdir=$(resolve_abs_parentdir ${installdir})
    if [ ! -d "$installdir" ]; then
        echo "Installation directory does not exist"
        echo "Creating $installdir"
        mkdir -p $installdir
    fi
    installdir=$(resolve_abs_path ${installdir})
    if [ "$installdir" == $(pwd -P) ]; then
        installdir="$(pwd -P)/local"
        mkdir -p $installdir
    fi
    echo "Installation directory at $installdir"
    echo 

    # Desktop Environment [cli/lxde/mate]
    echo "Enter Desktop Environment [cli/lxde/mate]"
    read -p "deskenv> " deskenv
    echo

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
fi

# Test inputs
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
    echo "Invalid Applications Directory"
fi

echo "Checking deskdir> $deskdir"
validfile=false
for i in $appdir/*.directory; do
    if [[ -e $i ]]; then
        echo " - contains *.directory file(s)"
        validfile=true
        break
    fi
done
if [ "$validfile" = false ]; then
    echo "Invalid Desktop Directory"
fi

