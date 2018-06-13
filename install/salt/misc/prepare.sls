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
{% if grains['id'] == "manage01"  %}
/usr/local/bin/domain-cli:
  file.managed:
    - source: salt://misc/file/bin/domain-cli
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/domain-cli
{% endif %}
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

/usr/local/bin/ctop:
  file.managed:
    - source: salt://misc/file/bin/ctop
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/ctop

/usr/local/bin/yq:
  file.managed:
    - source: salt://misc/file/bin/yq
    - mode: 755
    - user: root
    - group: root
    - unless: test -f /usr/local/bin/yq

{% if "manage" in grains['id'] %}
{% if pillar.domain is defined %}
compose_file:
  file.managed:
     - source: salt://misc/files/docker-compose.yaml
     - name: {{ pillar['rbd-path'] }}/docker-compose.yaml
     - makedirs: True
     - template: jinja
{% endif %}
{% endif %}