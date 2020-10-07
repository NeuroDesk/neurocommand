source utils/configparser.sh

filename="config.ini"
section="vnm"
GetINISection "$filename" "$section"

appmenudir="$(dirname "${vnm[appmenu]}")"

echo "WARNING: Will modify/replace system files!!!"
read -p "Press enter to continue ..."
mv -vn ${vnm[appmenu]}.BAK ${vnm[appmenu]}
