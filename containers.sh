#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##
_base="$(dirname $_script)" ## Delete last component from $_script ##
source neurodesk/configparser.sh ${_base}/config.ini

install_all_containers="false"

if [ "$1" != "" ]; then
    echo "Installing all containers"
    install_all_containers="true"
fi

echo "------------------------------------"
echo "to install ALL containers, run:"
echo "bash containers.sh --all"
echo "------------------------------------"
echo "to install individual containers, run:"
echo
while read appsh; do
      arrayIn=(${appsh//_/ })
      appcat=${arrayIn[@]:3}
      appcat_clean=${appcat:11:-1}                                                                                                                                                           
      apphead="| ${arrayIn[0]} | ${arrayIn[1]} | ${arrayIn[2]} | ${appcat_clean} | Run:"
      appfetch="./local/fetch_containers.sh ${arrayIn[0]} ${arrayIn[1]} ${arrayIn[2]}"

    eval $(echo printf '"%.0s-"' {1..${#apphead}})
    echo
    echo $apphead
    eval $(echo printf '"%.0s-"' {1..${#apphead}})
    echo
    echo $appfetch
    echo

 if [ "$install_all_containers" = "true" ]; then
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

echo "------------------------------------"
echo "to install ALL containers, run:"
echo "bash containers.sh --all"
echo "------------------------------------"
echo "to install individual containers, run the above listed commands for each application"
