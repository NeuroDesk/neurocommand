sudo docker build -t vnm:latest . --file vnm/Dockerfile && (
    echo "Starting VNM:"
    # sudo docker run -d --privileged --name vnm -v /vnm:/vnm -e RESOLUTION=1920x990 -p 6080:80 -p 5900:5900 vnm:latest
    # sudo docker run -d --privileged --name vnm -v /vnm:/vnm -e RESOLUTION=1280x680 -e USER=neuro -p 6080:80 -p 5900:5900 vnm:latest
    sudo docker run -d --privileged --name vnm -v ~/vnm:/vnm -e RESOLUTION=1600x960 -e USER=neuro -p 6080:80 -p 5900:5900 vnm:latest
    read -e -p "VNM is running - press ENTER key to shutdown and quit VNM!" check
    sudo docker stop vnm
    sudo docker rm vnm
) || (
    echo "-------------------------"
    echo "Docker Build failed!"
    echo "-------------------------"
)

# debug
# sudo docker build -t vnm:latest . --file vnm_base/Dockerfile && sudo docker run --privileged --name vnm -v /vnm:/vnm -e RESOLUTION=1600x960 -e USER=neuro -p 6080:80 -p 5900:5900 vnm:latest
