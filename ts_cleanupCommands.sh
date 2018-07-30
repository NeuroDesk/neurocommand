for executable in `cat commands.txt`; do
      echo $executable
      rm $executable
done

