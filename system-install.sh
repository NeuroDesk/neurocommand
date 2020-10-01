#!/bin/bash
# Read and parse single section in INI file 
# Credit https://blog.sleeplessbeastie.eu/2019/11/11/how-to-parse-ini-configuration-file-using-bash/

# Get/Set single INI section
GetINISection() {
  local filename="$1"
  local section="$2"

  array_name="${section}"
  declare -g -A ${array_name}
  eval $(awk -v configuration_array="${array_name}" \
             -v members="$section" \
             -F= '{ 
                    if ($1 ~ /^\[/) 
                      section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1)) 
                    else if ($1 !~ /^$/ && $1 !~ /^;/) {
                      gsub(/^[ \t]+|[ \t]+$/, "", $1); 
                      gsub(/[\[\]]/, "", $1);
                      gsub(/^[ \t]+|[ \t]+$/, "", $2);
                      if (section == members) {
                        if (configuration[section][$1] == "")  
                          configuration[section][$1]=$2
                        else
                          configuration[section][$1]=configuration[section][$1]" "$2}
                      }
                    } 
                    END {
                        for (key in configuration[members])  
                          print configuration_array"[\""key"\"]=\""configuration[members][key]"\";"
                    }' ${filename}
        )
}

filename="neurodesk.ini"
section="vnm"
GetINISection "$filename" "$section"



appmenudir="$(dirname "${vnm[appmenu]}")"

echo "WARNING: Will modify/replace system files!!!"
echo "sed '/DefaultMergeDirs/ a <MergeFile>vnm-applications.menu</MergeFile>' ${vnm[appmenu]} > ${vnm[installdir]}/lxde-applications.menu"
echo "mv ${vnm[appmenu]} ${vnm[appmenu]}.BAK"
echo "ln -s ${vnm[installdir]}/menus/lxde-applications.menu $appmenudir"
echo "ln -s ${vnm[installdir]}/menus/vnm-applications.menu $appmenudir"

echo "cp ${vnm[installdir]}/menus/desktop-directories/vnm-*.directory ${vnm[deskdir]}"
echo "cp ${vnm[installdir]}/menus/desktop-directories/vnm-*.desktop ${vnm[appdir]}"