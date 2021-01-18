#!/bin/bash

# python -m neurodesk $@

# https://stackoverflow.com/a/21188136
get_abs_filename() {
  # $1 : relative filename
  filename=$1
  parentdir=$(dirname "${filename}")

  if [ -d "${filename}" ]; then
      echo "$(cd "${filename}" && pwd)"
  elif [ -d "${parentdir}" ]; then
    echo "$(cd "${parentdir}" && pwd)/$(basename "${filename}")"
  fi
}
# read -p "deskenv: " deskenv
read -e -p "installdir: " installdir
# read -p "appmenu: " appmenu
# read -p "appdir: " appdir
# read -p "deskdir: " deskdir
# read -p "edit: " edit
# read -p "sh_prefix: " sh_prefix

get_abs_filename $installdir
readlink -f $installdir
realpath $installdir

case $installdir in
  /*) echo "absolute path" ;;
  *) echo "something else" ;;
esac
