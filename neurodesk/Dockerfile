# start from our VNM base image
FROM docker.pkg.github.com/neurodesk/vnm/neurodesk_base:20210106

COPY . /neurodesk/

WORKDIR /neurodesk
RUN bash build.sh --cli