# start from our VNM image
FROM docker.pkg.github.com/neurodesk/vnm/vnm:20201109

COPY neurodesk /neurodesk

WORKDIR /neurodesk
RUN bash build.sh --lxde --edit
RUN bash install.sh