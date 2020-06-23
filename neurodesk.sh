POSITIONAL=()
while [[ $# -gt 0 ]]
   do
   key="$1"

   case $key in
      -d|--installdir)
      installdir="$2"
      shift # past argument
      shift # past value
      ;;
      -c|--container)
      containerName="$2"
      shift # past argument
      shift # past value
      ;;
      --default)
      DEFAULT=YES
      shift # past argument
      ;;
      *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
   esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -n $1 ]]; then
    container="$1"
fi

if [ -z "$containerName" ]; then
    cat README.md
    echo Enter container filename:
    read containerName
fi

if [ -z "$installdir" ]; then
    echo Enter installation directory:
    read installdir
fi

if [ -z "$installdir" ]; then
    installdir=`pwd -P`
fi

# create folder structure for CVL
mkdir -p $installdir/containers
mkdir -p $installdir/xdg_data_dirs/applications
mkdir -p $installdir/xdg_data_dirs/desktop-directories
mkdir -p $installdir/xdg_config_dirs/menus

cd containers

git clone https://github.com/neurodesk/transparent-singularity.git "${containerName%.sif}"
cd "${containerName%.sif}"
./run_transparent_singularity.sh $containerName --cvl true
