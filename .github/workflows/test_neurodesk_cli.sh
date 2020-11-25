#!/usr/bin/env bash
# set -e

echo "checking if neurodesk installs and a containers gets downloaded correctly"

#creating logfile with available containers

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
echo "python version is ... "
python --version
echo "where am I"
pwd
echo "whoami"
whoami
echo "ls -la"
ls -la
mkdir testing
ls -la 
python -m neurodesk $@
ls -la 
bash build.sh --cli --lxde
# sudo bash build.sh --cli --lxde
cat all_execs.sh

