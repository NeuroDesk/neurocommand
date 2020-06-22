curl -s -S -X GET https://swift.rc.nectar.org.au:8888/v1/AUTH_d6165cc7b52841659ce8644df1884d5e/singularityImages

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
./run_transparent_singularity.sh $containerName --cvl true