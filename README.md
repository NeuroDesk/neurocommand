# neurodesk
neurodesk makes containerized applications available on any linux system with singularity installed

## Requirements:
- singularity (https://sylabs.io/guides/3.5/user-guide/quick_start.html)  
- lmod (https://lmod.readthedocs.io/en/latest/)  
- python (https://docs.conda.io/en/latest/miniconda.html#linux-installers)  

## Linux 
### Inital install
#### CLI mode - For non-desktop experiance  
If running on cli only ...  
Run `bash build.sh --cli --lxde` to install in cli mode  
Run `bash containers.sh` for installing all containers  

#### For Lxde desktops

If running on an lxde desktop...
Run `bash build.sh --lxde`

#### For Mate desktops

Run `bash build.sh --init`  (or `bash build.sh --lxde`)  
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
1. Setup WSL/WSL2 using the following instructions _(Ubuntu 18.04 recommended)_  
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
