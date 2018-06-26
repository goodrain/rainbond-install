{% if pillar.etcd.server.enabled %}
{% if "manage" in grains['id'] %}
etcd-env:
  file.managed:
    - source: salt://etcd/install/envs/etcd.sh
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
    - source: salt://etcd/install/envs/etcd-proxy.sh
    - name: {{ pillar['rbd-path'] }}/envs/etcd-proxy.sh
    - template: jinja
    - makedirs: True
    - mode: 644
    - user: root
    - group: root
{% endif %}
{% endif %}

calico-env:
  file.managed:
    - source: salt://network/calico/install/envs/calico.sh
    - name: {{ pillar['rbd-path'] }}/envs/calico.sh
    - template: jinja
    - makedirs: True
    - mode: 644
    - user: root
    - group: root

kubelet-env:
  file.managed:
    - source: salt://kubernetes/node/install/envs/kubelet.sh
    - name: {{ pillar['rbd-path'] }}/envs/kubelet.sh
    - makedirs: True
    - template: jinja
    - mode: 644
    - user: root
    - group: root

getip:
  file.managed:
    - source: salt://init/files/bin/myip
    - name: {{ pillar['rbd-path'] }}/envs/.myip
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

{% if grains['id'] == "manage01" %}
add_getip_modules:
  file.managed:
    - source: salt://init/files/getip.py
    - name: /srv/salt/_modules/getip.py
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root
{% endif %}

