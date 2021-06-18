docker build -t vnm:latest . --file vnm/Dockerfile && (
    ECHO "Starting VNM:"
    docker images
    REM docker run -d --privileged --name vnm -v C:/vnm:/vnm -p 6080:80 -p 5900:5900 vnm:latest
    REM docker run -d --privileged --name vnm -v C:/vnm:/vnm -e RESOLUTION=1920x990 -p 6080:80 -p 5900:5900 vnm:latest
    docker run -d --privileged --name vnm -v C:/vnm:/vnm -e RESOLUTION=1600x960 -e USER=neuro -p 6080:80 -p 5900:5900 vnm:latest
    set /p=VNM is running - press ENTER key to shutdown and quit VNM!
    docker stop vnm
    docker rm vnm
) || (
    echo "-------------------------"
    echo "Docker Build failed!"
    echo "-------------------------"
)


