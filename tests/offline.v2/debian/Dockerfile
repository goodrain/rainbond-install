FROM debian:9.5

RUN apt update && apt-get install --no-install-recommends --no-install-suggests -y gnupg apt-transport-https ca-certificates procps curl wget && \
    wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub |  apt-key add - && \
    curl http://repo.goodrain.com/gpg/goodrain-C4CDA0B7 |  apt-key add - && \
    apt-get remove --purge --auto-remove wget curl -y --allow-remove-essential && \
    rm -rf /var/lib/apt/lists/* 

ADD rbd.list /etc/apt/sources.list.d/rbd.list

#ADD yq /usr/bin/yq

ADD download.sh /download.sh

#RUN chmod +x download.sh /usr/bin/yq

ENTRYPOINT [ "/download.sh" ]
