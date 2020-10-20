for executable in `cat commands.txt`; do
      echo $executable
      rm $executable
done

rm -rf activate*
rm -rf deactivate*
rm commands.txt
rm *.sif

