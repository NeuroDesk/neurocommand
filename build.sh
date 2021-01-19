#!/bin/bash

# python -m neurodesk $@
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

# Installation Directory [./local]
read -e -p "installdir: " installdir
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
echo "Installation directory is $installdir"


exit
# Desktop Environment [cli/lxde/mate]
read -p "deskenv: " deskenv

# Applications Menu
read -e -p "appmenu: " appmenu
appmenu=$(get_abs_filepath $appmenu)

# Applications Directory
read -e -p "appdir: " appdir
appdir=$(get_abs_dirpath $appdir)

# Desktop Directories
read -e -p "deskdir: " deskdir
deskdir=$(get_abs_dirpath $deskdir)

# Edit mode [y/n]
read -p "edit : " edit
