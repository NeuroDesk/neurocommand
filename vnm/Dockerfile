# start from our VNM base image
FROM docker.pkg.github.com/neurodesk/vnm/vnm_base:20210129

COPY . /neurodesk/

WORKDIR /neurodesk

RUN bash build.sh --lxde --edit \
    && bash install.sh \
    && ln -s /vnm/containers /neurodesk/local/containers \
    && mkdir -p /etc/skel/Desktop/ \
    && ln -s /vnm /etc/skel/Desktop/ \
    && sed -i '/DefaultMergeDirs/ a <MergeFile>vnm-applications.menu</MergeFile>' /etc/xdg/menus/lxde-applications.menu