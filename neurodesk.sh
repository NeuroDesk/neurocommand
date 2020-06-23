cat README.md 

echo Enter container filename:
read containerName

# create folder structure for CVL
if [ ! -d "containers" ]; then
  mkdir -p containers
  mkdir -p xdg_data_dirs/applications
  mkdir -p xdg_data_dirs/desktop-directories
  mkdir -p xdg_config_dirs/menus
fi

cd containers

git clone https://github.com/neurodesk/transparent-singularity.git "${containerName%.sif}"
cd "${containerName%.sif}"
./run_transparent_singularity.sh --container $containerName --cvl true 