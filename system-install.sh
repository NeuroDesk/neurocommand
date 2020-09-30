#!/bin/bash
# Read and parse single section in INI file 
# Credit https://blog.sleeplessbeastie.eu/2019/11/11/how-to-parse-ini-configuration-file-using-bash/

# Get/Set single INI section
GetINISection() {
  local filename="$1"
  local section="$2"

  array_name="cfg${section}"
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

echo "[${section}]"
for key in $(eval echo $\{'!'cfg${section}[@]\}); do
        echo -e "  ${key} = $(eval echo $\{cfg${section}[$key]\}) (access it using $(echo $\{cfg${section}[$key]\}))"
done

# mv /etc/xdg/menus/lxde-applications.menu /etc/xdg/menus/lxde-applications.menu.BAK
# ln -s ${installdir}/menus/lxde-applications.menu /etc/xdg/menus/
# chmod 644 /etc/xdg/menus/lxde-applications.menu

# ln -s ${installdir}/menus/vnm-applications.menu /etc/xdg/menus/
# chmod 644 /etc/xdg/menus/vnm-applications.menu

