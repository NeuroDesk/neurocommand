#!/usr/bin/env bash
# set -e

echo "checking if containers are built"

#creating logfile with available containers
cd neurodesk
python write_log.py

# remove empty lines
sed -i '/^$/d' log.txt

# remove square brackets
sed -i 's/[][]//g' log.txt

# remove spaces around
sed -i -e 's/^[ \t]*//' -e 's/[ \t]*$//' log.txt

# replace spaces with underscores
sed -i 's/ /_/g' log.txt


while IFS= read -r IMAGENAME_BUILDDATE
do
  echo "$IMAGENAME_BUILDDATE"
    if curl --output /dev/null --silent --head --fail "https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages/${IMAGENAME_BUILDDATE}.sif"; then
        echo "${IMAGENAME_BUILDDATE}.sif exists"
    else
        echo "${IMAGENAME_BUILDDATE}.sif does not exist yet"
        exit 2
    fi
done < log.txt

# check if the installer runs:
# Currently doesn't work because it somehow uses Python2?
# testing neurodocker installer ... 
# python version is ... 
# Python 3.8.6
# Traceback (most recent call last):
#   File "/usr/lib/python2.7/runpy.py", line 174, in _run_module_as_main
#     "__main__", fname, loader, pkg_name)
#   File "/usr/lib/python2.7/runpy.py", line 72, in _run_code
#     exec code in run_globals
#   File "/home/runner/work/neurodesk/neurodesk/neurodesk/__main__.py", line 1, in <module>
#     from neurodesk import neurodesk
#   File "neurodesk/neurodesk.py", line 47
#     def vnm_xml(xml: Path, newxml: Path) -> None:
#                    ^
# SyntaxError: invalid syntax
# neurodesk/configparser.sh: line 18: /home/runner/work/neurodesk/neurodesk/neurodesk/config.ini: No such file or directory
# /home/runner/work/neurodesk/neurodesk/neurodesk/config.ini
# WARNING: Will modify/replace system files!!!
# !!! Add <MergeFile>vnm-applications.menu</MergeFile> to  !!!
# ln: failed to create symbolic link '/vnm': File exists
# cd ..
# sudo apt install lxde
# echo "testing neurodocker installer ... "
# echo "python version is ... "
# python --version
# sudo bash build.sh --lxde --edit
# sudo bash install.sh
