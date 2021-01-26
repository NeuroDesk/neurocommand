#!/bin/bash

if [ $# -eq 0 ]; then
    _script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
    _base="$(dirname $_script)" ## Delete last component from $_script ##
    filename="${_base}/config.ini"
else
    filename=$1
fi

if [ -f "$filename" ]; then
    echo $filename
    while IFS='= ' read key value
    do
        if [[ $key == \[*] ]]
        then
            section=${key#*[}
            section=${section%]*}
        elif [[ $value ]]
        then
            declare "${section}_${key}=$value"
        fi
    done < $filename

    vnm_appmenudir="$(dirname "${vnm_appmenu}")"
    vnm_appmenufile="$(basename "${vnm_appmenu}")"
fi
