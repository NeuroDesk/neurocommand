#!/bin/bash

if [[ -z "$1" ]] || [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    echo "Shows or installs available Neurodesk containers"
    echo
    echo "Usage:"
    echo "  $0 all         # Shows all available Neurodesk containers"
    echo "  $0 --all       # Installs all available Neurodesk containers"
    echo "  $0 PATTERN     # Shows all containers that match PATTERN"
    echo "  $0 --PATTERN   # Installs all containers that match PATTERN"
    echo
    echo "Examples:"
    echo "  $0 all"
    echo "  $0 diffusion"
    echo "  $0 --bidscoin"
    echo
    exit 1
fi

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
source neurodesk/configparser.sh ${_base}/config.ini

install="false"
pattern=$1
if [ ${1:0:2} = '--' ]; then
    install="true"
    pattern=${1:2}
fi

echo "--------------------------------------" 
if [ "$install" = "true" ]; then
    echo "Installing *${pattern}* containers"
else
    echo "To install ALL containers, run:"
    echo "$0 --all"
    echo "--------------------------------------"
    echo "To install individual containers, run:"
fi
echo "--------------------------------------"
echo

while read appsh; do

    arrayIn=(${appsh//_/ })
    if [ "$pattern" != "all" ] && [[ ${arrayIn[0]} != *${pattern}* ]]; then
        continue
    fi
    appcat=${arrayIn[@]:3}
    appcat_clean=${appcat:11:-1}                                                                                                                                                           
    apphead="| ${arrayIn[0]} | ${arrayIn[1]} | ${arrayIn[2]} | ${appcat_clean} | Run:"
    appfetch="./neurodesk/fetch_containers.sh ${arrayIn[0]} ${arrayIn[1]} ${arrayIn[2]}"

    eval $(echo printf '"%.0s-"' {1..${#apphead}})
    echo
    echo $apphead
    eval $(echo printf '"%.0s-"' {1..${#apphead}})
    echo
    echo $appfetch
    echo

    if [ "$install" = "true" ]; then
        eval $appfetch
        err=$?
        if [ $err -eq 0 ] ; then
            installmsg="| SUCCESS | ${arrayIn[0]} ${arrayIn[1]} ${arrayIn[2]} | $(date)"
            eval $(echo printf '"%.0s-"' {1..${#installmsg}})
            echo
            echo $installmsg
            eval $(echo printf '"%.0s-"' {1..${#installmsg}})
            echo
            echo
            echo
        else
            installmsg="| FAILED | ${arrayIn[0]} ${arrayIn[1]} ${arrayIn[2]} | $(date)"
            eval $(echo printf '"%.0s-"' {1..${#installmsg}})
            echo
            echo $installmsg
            eval $(echo printf '"%.0s-"' {1..${#installmsg}})
            echo
            echo
            echo "Existing due to install error(s) ..."
            echo
            exit
        fi
    fi

done < cvmfs/log.txt
