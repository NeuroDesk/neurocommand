# start from our VNM image
FROM docker.pkg.github.com/neurodesk/vnm/vnm:20201118

COPY . /neurodesk/

WORKDIR /neurodesk
RUN bash build.sh --lxde --edit
RUN bash install.sh