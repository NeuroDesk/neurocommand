#!/bin/bash

# List of directories to check and create if missing
required_dirs=("data" "mnt" "neurodesktop-storage" "tmp" "cvmfs")

# Loop through each target directory two levels deep
for dir in /cvmfs/neurodesk.ardc.edu.au/containers/*/*.simg; do
  # Ensure it's a directory
  if [ -d "$dir" ]; then
    # Check each required directory within this directory
    for sub_dir in "${required_dirs[@]}"; do
      # If the required subdirectory is missing, create it as root
      if [ ! -d "$dir/$sub_dir" ]; then
        sudo mkdir "$dir/$sub_dir"
        echo "Created directory as root: $dir/$sub_dir"
      fi
    done
  fi
done

