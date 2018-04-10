/usr/local/bin/calicoctl:
  file.managed:
    - source: salt://misc/file/bin/calicoctl
    - file_mode: 755
    - unless: test -f /usr/local/bin/calicoctl

/usr/local/bin/dc-compose:
  file.managed:
    - source: salt://misc/file/bin/dc-compose
    - file_mode: 755
    - unless: test -f /usr/local/bin/dc-compose

{% if "manage" in grains['host'] %}
/usr/local/bin/etcdctl:
  file.managed:
    - source: salt://misc/file/bin/etcdctl
    - file_mode: 755
    - unless: test -f /usr/local/bin/etcdctl

/usr/local/bin/grctl:
  file.managed:
    - source: salt://misc/file/bin/grctl
    - file_mode: 755
    - unless: test -f /usr/local/bin/grctl

/usr/local/bin/kubectl:
  file.managed:
    - source: salt://misc/file/bin/kubectl
    - file_mode: 755
    - unless: test -f /usr/local/bin/kubectl
{% endif %}

{% if "compute" in grains['host'] %}
/usr/local/bin/kubelet:
  file.managed:
    - source: salt://misc/file/bin/kubelet
    - file_mode: 755
    - unless: test -f /usr/local/bin/kubelet
{% endif %}

/usr/local/bin/node:
  file.managed:
    - source: salt://misc/file/bin/node
    - file_mode: 755
    - unless: test -f /usr/local/bin/node