FROM centos:7.4.1708

ADD rbd.repo /etc/yum.repos.d/rbd.repo

#ADD yq /usr/bin/yq

ADD download.sh /download.sh

#RUN chmod +x download.sh /usr/bin/yq

RUN chmod +x download.sh

ENTRYPOINT [ "/download.sh" ]
