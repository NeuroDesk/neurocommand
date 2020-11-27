# neurodesk
neurodesk makes containerized applications available on any linux system with singularity installed

## Run Desktop with neurodesk installed in a Docker container
https://github.com/NeuroDesk/vnm/



## Linux 
### Requirements:
- python (https://docs.conda.io/en/latest/miniconda.html#linux-installers)  
- singularity (https://sylabs.io/guides/3.5/user-guide/quick_start.html)  
- lmod (https://lmod.readthedocs.io/en/latest/)  

### Inital install
#### command line mode - For non-desktop experience (e.g. running on an HPC)  
If running on cli only ... 
Load singularity and for best performance it should be 3.x e.g. `module load singularity/3.5.0` 
Run `git clone https://github.com/NeuroDesk/neurodesk.git` to clone the repository
Run `cd neurodesk` to change into the directory
Run `bash build.sh --cli` to install in cli mode  
Run `bash containers.sh` for installing indiviual containers or `bash containers.sh --all` for installing all containers
Run `module use $PWD/local/containers/modules/` to add the containers to your module search path. Add this to your .bashrc if working.

#### For Lxde desktops
If running on an lxde desktop...
Run `bash build.sh --lxde --edit`

#### For Mate desktops
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
Run `bash containers.sh`

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

#### Running
1. `sudo service xrdp start` to start xrdp server
2. Open Microsoft Remote Desktop Connection in Windows host
3. Connect to `localhost:3390`  
_An LXDE desktop should as a Microsoft Remote Desktop_  
4. Follow Linux guide from here on
