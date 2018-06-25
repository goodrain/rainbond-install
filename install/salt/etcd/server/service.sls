{% if pillar.etcd.server.enabled %}
{% set ETCDIMG = salt['pillar.get']('etcd:server:image') -%}
{% set ETCDVER = salt['pillar.get']('etcd:server:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

pull-etcd-image:
  cmd.run:
{% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}
{% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ ETCDIMG }}_{{ ETCDVER }}.gz
{% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ ETCDIMG }}:{{ ETCDVER }}

etcd-tag:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/{{ETCDIMG}}:{{ETCDVER}} {{PRIDOMAIN}}/{{ETCDIMG}}:{{ETCDVER}}
    - unless: docker inspect {{PRIDOMAIN}}/{{ETCDIMG}}:{{ETCDVER}}
    - require:
      - cmd: pull-etcd-image
  
etcd-env:
  file.managed:
    - source: salt://etcd/install/envs/etcd.sh
    - name: {{ pillar['rbd-path'] }}/envs/etcd.sh
    - template: jinja
    - makedirs: True
    - mode: 644
    - user: root
    - group: root

etcd-script:
  file.managed:
    - source: salt://etcd/install/scripts/start-etcd.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-etcd.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/etcd.service:
  file.managed:
    - source: salt://etcd/install/systemd/etcd.service
    - template: jinja
    - user: root
    - group: root

{% if grains['id'] != "manage01" %}

add-cluster-script:
  file.managed:
    - source: salt://etcd/install/scripts/add-cluster.sh
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
      - file: etcd-env
      - cmd: pull-etcd-image
    - require:
      - file: /etc/systemd/system/etcd.service
      - file: etcd-script
      - file: etcd-env
      - cmd: pull-etcd-image
  
{% endif %}

