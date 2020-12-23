# start from our VNM base image
FROM docker.pkg.github.com/neurodesk/vnm/neurodesk_base:20201223

COPY . /neurodesk/

WORKDIR /neurodesk
RUN which python3
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN bash build.sh --lxde --edit
RUN bash install.sh