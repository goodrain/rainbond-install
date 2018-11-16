/usr/local/bin/calicoctl:
  file.managed:
    - source: salt://install/files/misc/bin/calicoctl
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/docker-compose:
  file.managed:
    - source: salt://install/files/misc/bin/docker-compose
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/kubectl:
  file.managed:
    - source: salt://install/files/misc/bin/kubectl
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/etcdctl:
  file.managed:
    - source: salt://install/files/misc/bin/etcdctl
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/kubelet:
  file.managed:
    - source: salt://install/files/misc/bin/kubelet
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/node:
  file.managed:
    - source: salt://install/files/misc/bin/node
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/ctop:
  file.managed:
    - source: salt://install/files/misc/bin/ctop
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/yq:
  file.managed:
    - source: salt://install/files/misc/bin/yq
    - mode: 755
    - user: root
    - group: root


/usr/local/bin/grcert:
  file.managed:
    - source: salt://install/files/misc/bin/grcert
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/grctl:
  file.managed:
    - source: salt://install/files/misc/bin/grctl
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/domain-cli:
  file.managed:
    - source: salt://install/files/misc/bin/domain-cli
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/scope:
  file.managed:
    - source: salt://install/files/misc/bin/scope
    - mode: 755
    - user: root
    - group: root

{% if grains['id'] == 'manage01' %}
{% set sslpath = "/srv/salt/install/files/ssl/region" %}
region-ssl-ca:
  cmd.run:
    - name: /srv/salt/install/files/misc/bin/grcert create --is-ca --ca-name={{ sslpath }}/ca.pem --ca-key-name={{ sslpath }}/ca.key.pem
    - unless: ls -l {{ sslpath }}/ca.pem

region-server-ssl:
  cmd.run:
    - name: /srv/salt/install/files/misc/bin/grcert create --ca-name={{ sslpath }}/ca.pem --ca-key-name={{ sslpath }}/ca.key.pem --crt-name={{ sslpath }}/server.pem --crt-key-name={{ sslpath }}/server.key.pem --domains region.goodrain.me --address={{ pillar['vip'] }} --address=127.0.0.1
    - unless: ls -l {{ sslpath }}/server.pem

region-client-ssl:
  cmd.run:
    - name: /srv/salt/install/files/misc/bin/grcert create --ca-name={{ sslpath }}/ca.pem --ca-key-name={{ sslpath }}/ca.key.pem --crt-name={{ sslpath }}/client.pem --crt-key-name={{ sslpath }}/client.key.pem --domains region.goodrain.me --address={{ pillar['vip'] }} --address=127.0.0.1
    - unless: ls -l {{ sslpath }}/client.pem
{% endif %}
