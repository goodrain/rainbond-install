{% set ETCDIMG = salt['pillar.get']('etcd:server:image') -%}
{% set ETCDVER = salt['pillar.get']('etcd:server:version') -%}
{% set ETCDPROXYIMG = salt['pillar.get']('etcd:proxy:image') -%}
{% set ETCDPROXYVER = salt['pillar.get']('etcd:proxy:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

{% if "manage" in grains['id'] %}
{% if pillar.etcd.server.enabled %}
etcd-script:
  file.managed:
    - source: salt://install/files/etcd/install/scripts/start-etcd.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-etcd.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/etcd.service:
  file.managed:
    - source: salt://install/files/etcd/install/systemd/etcd.service
    - template: jinja
    - user: root
    - group: root

{% if grains['id'] != "manage01" %}

add-cluster-script:
  file.managed:
    - source: salt://install/files/etcd/install/scripts/add-cluster.sh
    - name: /tmp/add-cluster.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

etcd-add-cluster:
  cmd.run:
    - name: bash /tmp/add-cluster.sh
{% endif %}

etcd:
  service.running:
    - enable: True
    - watch:
      - file: etcd-script
    - require:
      - file: /etc/systemd/system/etcd.service
      - file: etcd-script
  
{% endif %}
{% else %}
{% if pillar.etcd.proxy.enabled %}

pull-etcd-proxy-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ ETCDPROXYIMG }}:{{ ETCDPROXYVER }}

etcd-proxy-script:
  file.managed:
    - source: salt://install/files/etcd/install/scripts/start-etcdproxy.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-etcdproxy.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/etcd-proxy.service:
  file.managed:
    - source: salt://install/files/etcd/install/systemd/etcd-proxy.service
    - template: jinja
    - user: root
    - group: root

etcd-proxy:
  service.running:
    - enable: True
    - watch:
      - file: etcd-proxy-script
      - cmd: pull-etcd-proxy-image
    - require:
      - file: /etc/systemd/system/etcd-proxy.service
      - file: etcd-proxy-script
      - cmd: pull-etcd-proxy-image

{% endif %}
{% endif %}