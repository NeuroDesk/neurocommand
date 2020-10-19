# neurodesk
neurodesk makes containerized applications available on any linux system with singularity installed

## Requirements:
- singularity 
- lmod


## Linux 
Run `bash build.sh --init`  (or `bash build.sh --lxde`)  
Run `bash containers.sh`

(Install) `sudo bash install.sh`  
_Creates symlinks to menu files in installation dir_  
  
(Uninstall) `sudo bash uninstall.sh`  
_Removes symlinks_  

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
