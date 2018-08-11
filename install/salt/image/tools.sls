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