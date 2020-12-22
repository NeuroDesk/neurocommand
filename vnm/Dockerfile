# start from our VNM base image
FROM docker.pkg.github.com/neurodesk/vnm/vnm_base:20201222

COPY . /neurodesk/

WORKDIR /neurodesk
RUN bash build.sh --lxde --edit
RUN bash install.sh