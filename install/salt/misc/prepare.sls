/usr/local/bin/calicoctl:
  file.managed:
    - source: salt://misc/file/bin/calicoctl
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/calicoctl

/usr/local/bin/docker-compose:
  file.managed:
    - source: salt://misc/file/bin/docker-compose
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/docker-compose

{% if "manage" in grains['id'] %}
/usr/local/bin/etcdctl:
  file.managed:
    - source: salt://misc/file/bin/etcdctl
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/etcdctl

/usr/local/bin/grctl:
  file.managed:
    - source: salt://misc/file/bin/grctl
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/grctl

/usr/local/bin/kubectl:
  file.managed:
    - source: salt://misc/file/bin/kubectl
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/kubectl
{% endif %}

{% if "compute" in grains['id'] %}
/usr/local/bin/kubelet:
  file.managed:
    - source: salt://misc/file/bin/kubelet
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/kubelet
{% endif %}

/usr/local/bin/node:
  file.managed:
    - source: salt://misc/file/bin/node
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/node