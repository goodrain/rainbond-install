{% if pillar.etcd.server.enabled %}
{% if "manage" in grains['id'] %}
etcd-env:
  file.managed:
    - source: salt://install/files/etcd/envs/etcd.sh
    - name: {{ pillar['rbd-path'] }}/envs/etcd.sh
    - template: jinja
    - makedirs: True
    - mode: 644
    - user: root
    - group: root
{% endif %}
{% endif %}

{% if pillar.etcd.proxy.enabled %}
{% if "compute" in grains['id'] %}
etcd-proxy-env:
  file.managed:
    - source: salt://install/files/etcd/envs/etcd-proxy.sh
    - name: {{ pillar['rbd-path'] }}/envs/etcd-proxy.sh
    - template: jinja
    - makedirs: True
    - mode: 644
    - user: root
    - group: root

{% endif %}
{% endif %}

getip:
  file.managed:
    - source: salt://install/files/init/bin/myip
    - name: {{ pillar['rbd-path'] }}/envs/.myip
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root