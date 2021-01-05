#test for singularity install
echo "checking for singularity ..."
qq=`which  singularity`
if [[  ${#qq} -lt 1 ]]; then
   echo "This script requires singularity on your path. E.g. add module load singularity/2.4.2 to your .bashrc"
   echo "If you are root try again as normal user"
   else
   echo "... found :)"
fi

#test for wget, curl, or aria2

#download neurodesk container

#run neurodesk container
