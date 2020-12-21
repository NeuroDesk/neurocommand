# start from our VNM image
FROM docker.pkg.github.com/neurodesk/vnm/vnm:20201221

COPY . /neurodesk/

WORKDIR /neurodesk
RUN bash build.sh --lxde --edit
RUN bash install.sh