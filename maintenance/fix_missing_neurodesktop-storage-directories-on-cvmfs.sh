# check:
for dir in /cvmfs/neurodesk.ardc.edu.au/containers/*/*; do
  if [ -d "$dir" ] && [ ! -d "$dir/neurodesktop-storage" ]; then
    echo "$dir"
  fi
done

# fix:
for dir in /cvmfs/neurodesk.ardc.edu.au/containers/*/*; do
  if [ -d "$dir" ] && [ ! -d "$dir/neurodesktop-storage" ]; then
    mkdir "$dir/neurodesktop-storage"
    echo "Created directory: $dir/neurodesktop-storage"
  fi
done


