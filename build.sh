#!/bin/bash

# python -m neurodesk $@

get_abs_filepath() {
    path="${1/#\~/$HOME}"
    parentdir=$(dirname "${path}")
    name=$(basename "${path}")
    echo "$(cd ${parentdir} && pwd -P)/${name}"
}

# Installation Directory [./local]
read -e -p "installdir: " installdir
get_abs_filepath $installdir

if [[ ! -d "$installdir" ]]; then
  echo "Installation Dir $installdir does not exist. Creating ..."
  mkdir $installdir
fi

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
