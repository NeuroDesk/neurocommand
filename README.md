# Neurocommand
Neurocommand is our command line interface for advanced users. To get an overview of the project refer to the website and documentation: https://neurodesk.github.io/


## Linux 
### Requirements:
- python3.6+ 
  - Recommend using Miniconda (https://docs.conda.io/en/latest/miniconda.html#linux-installers)
  - With virtual conda environments (https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html)
- singularity (https://sylabs.io/guides/3.5/user-guide/quick_start.html)  
- lmod (https://lmod.readthedocs.io/en/latest/)
- git

### Initial install
- Run `git clone https://github.com/NeuroDesk/neurocommand.git` to clone the repository - make sure to clone this to a directory with enough storage, write permissions and NOT a symbolic link (to be sure run cd \`pwd -P\`)!
- Run `cd neurocommand` to change into the directory
- Run `pip3 install -r neurodesk/requirements.txt --user` to install pre-requisite python packages

#### [Option 1] command line mode - For non-desktop experience (e.g. running on an HPC)  
If running on cli only ... 
- Load singularity and for best performance it should be 3.x e.g. `module load singularity/3.5.0` 
- Load or install aria2 to optimize the download performance of our containers e.g. `module load aria2c`
- make sure the current directory is not a symlink (singularity bug): `pwd -P` and then cd there
- export singularity bindpaths: `export SINGULARITY_BINDPATH=$PWD,$SINGULARITY_BINDPATH` 
- Run `bash build.sh --cli` to install in cli mode  
- Run `bash containers.sh` for installing indiviual containers or `bash containers.sh --all` for installing all containers
- Run `module use $PWD/local/containers/modules/` to add the containers to your module search path. Add this to your .bashrc if working.
- Run `module avail` to see the installed containers at the top of the list (neurodesk containers will take preference over system modules with the same name). If a container is not yet there run `ml --ignore_cache avail`

#### [Option 2] For Lxde desktops
If running on an lxde desktop...
Run `bash build.sh --lxde --edit`

#### [Option 3] For Mate desktops
Run `bash build.sh --init`  (or `bash build.sh --lxde --edit`)  
lxde/mate: Mate  
installdir: Where all the neurodesk files will be stored (Default: ./local)  
appmenu: The linux menu xml file.  (Usually /etc/xdg/menus/\*\*\*\*-applications.menu)  
appdir: Location for the .desktop files for this linux desktop (Usually /usr/share/applications)  
deskdir: Location for the .directory files for this linux desktop (Typically /usr/share/desktop-directories)  

#### For desktop menus:  

`sudo bash install.sh` to install  
_Creates symlinks to menu files in installation dir_  
  
`sudo bash uninstall.sh` to uninstall  
_Removes symlinks_  

### To update

Run `git pull`  
Run `bash build.sh`  
_install.sh does not need to be run again_

#### To download all containers
Run `bash containers.sh --all`

## Windows

### WSL (w/ Ubuntu + LXDE)
For more information on WSL: https://docs.microsoft.com/en-us/windows/wsl/  

#### Setting up
1. Setup WSL2 using the following instructions _(Ubuntu 18.04 recommended)_  
https://docs.microsoft.com/en-us/windows/wsl/install-win10  
_Proceed until a Ubuntu bash shell is available from the Windows Host_  
_Run the remaining commands in the Bash shell_
2. `sudo apt-get install lxde` to install LXDE desktop in WSL
3. Reboot
4. `sudo apt-get install xrdp` to install XRDP in WSL
5. Open `/etc/xrdp/xrdp.ini`
Change `port=3389` to `port=3390` and save
6. Run `echo startlxde > ~/.xsession`

#### Running
1. `sudo service xrdp start` to start xrdp server
2. Open Microsoft Remote Desktop Connection in Windows host
3. Connect to `localhost:3390`
4. In the next login page, leave Session as `Xorg`. Enter your WSL username and password and click `OK`
5. This should open an LXDE Linux Desktop environment. Follow Linux guide from here on
