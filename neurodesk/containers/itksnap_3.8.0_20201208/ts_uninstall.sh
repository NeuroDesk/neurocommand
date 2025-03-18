for executable in `cat commands.txt`; do
      echo $executable
      rm $executable
done

rm -rf activate*
rm -rf deactivate*
rm commands.txt
rm *.sif

rm /home/sebp/neurocommand/neurodesk/containers/itksnap_3.8.0_20201208/../modules/itksnap/3.8.0
