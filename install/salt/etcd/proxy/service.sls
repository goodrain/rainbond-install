{% if pillar.etcd.proxy.enabled %}
{% set ETCDPROXYIMG = salt['pillar.get']('etcd:proxy:image') -%}
{% set ETCDPROXYVER = salt['pillar.get']('etcd:proxy:version') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

pull-etcd-proxy-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ ETCDPROXYIMG }}:{{ ETCDPROXYVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{ ETCDPROXYIMG }}:{{ ETCDPROXYVER }}

etcd-proxy-script:
  file.managed:
    - source: salt://etcd/install/scripts/start-etcdproxy.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-etcdproxy.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

/etc/systemd/system/etcd-proxy.service:
  file.managed:
    - source: salt://etcd/install/systemd/etcd-proxy.service
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