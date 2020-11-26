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
bash build.sh --cli --lxde
bash containers.sh
bash /home/runner/work/neurodesk/neurodesk/local/fetch_containers.sh itksnap 3.8.0 20200811 itksnap /MRIcrop-orig.gipl

ls /home/runner/work/neurodesk/neurodesk/local/containers/itksnap_3.8.0_20200811

if [ -f /home/runner/work/neurodesk/neurodesk/local/containers/itksnap_3.8.0_20200811/itksnap_3.8.0_20200811.sif ]; then
    echo "Container file exists"
    exit 0
else 
    echo "Container file does not exist!!!!!!!!!"
    exit 1
fi