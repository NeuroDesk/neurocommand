#!/bin/bash
#Deploy script for minc-toolkit
#Creates wrapper scripts for all executables in a container's $PATH
#11/07/2018
#SB & TS

#Check if singularity is installed, if not ask for module load command

qq=`which  singularity`
    if [[  ${#qq} -lt 1 ]]; then
        echo "do you have singularity?  if not, then ... I don't know...install it?"
        #install singularity
        module load singularity/2.4.2
        #exit
	#apt-get singularity??? #FIXME
    fi

container=minc-toolkit-1.9.16.simg
container_web_address=shub://vfonov/minc-toolkit-containers:1.9.16

#pull image
#singularity pull --name $container $container_web_address

#figure out which executables exist
sudo singularity shell --bind $PWD:/mnt/ --pwd /mnt/ $container

IFS=':'; \
for i in $PATH; \
do test -d "$i" && find "$i" -maxdepth 1 -executable -type f -exec basename {} \;; done >> commands.txt
#FIXME commands.txt file path to be changed.


#create singularity executable for each regular executable in commands.txt
# $@ parses command line options.
 
for executable in `cat commands.txt`; do \
   echo $executable > /path/to/singularity_exacutables/${executable}; \
   echo "singularity exec --bind $PWD:/mnt/ --pwd /mnt/ $container /path/to/singularity_executables/$executable '$@'" > /path/to/singularity_executables/$executable
   chmod a+x $executable

done

#add /path/to/singularity_executables to your $PATH 
export PATH="/path/to/singularity_executables/:$PATH"
echo "export PATH="/path/to/singularity_executables/:$PATH"" >> ~/.bashrc
#Steffen FIXME figure out what order this needs to be appended.
#FIXME also need a solution for where we store the simg executables i.e. /path/to/singularity_executables. Perhaps with the container? e.g., mkdir ./simg_executables


#There will also be a problem with multiple containers and different versions. We should set up an executable script with each container
#that turns the executables on and off easily. 
#something like: 
touch /path/to/singularity_executables/TURNOFF_${container}
touch /path/to/singularity_executables/TURNON_${container}
echo "PATH=`echo $PATH | sed -e 's/:\/path\/to\/simg\/$//'`">>/path/to/simg/TURNOFF_${container}
echo "bash">>/path/to/simg/TURNOFF_${container}
echo "sed -e 's/:\/path\/to\/simg\/$//' ~/.bashrc">>/path/to/simg/TURNOFF_${container}
echo "export PATH="/path/to/singularity_executables/:$PATH"">>/path/to/simg/TURNON_${container}
echo "export PATH="/path/to/singularity_executables/:$PATH"">>~/.bashrc
echo "bash">>/path/to/simg/TURNON_${container}
