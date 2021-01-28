# start from our VNM base image
FROM docker.pkg.github.com/neurodesk/vnm/vnm_base:20210106

COPY . /neurodesk/

WORKDIR /neurodesk
RUN bash build.sh --lxde --edit
RUN bash install.sh