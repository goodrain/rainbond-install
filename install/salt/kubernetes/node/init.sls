kubelet-script:
  file.managed:
    - source: salt://kubernetes/node/install/scripts/start-kubelet.sh
    - name: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kubelet.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

kubelet-env:
  file.managed:
    - source: salt://kubernetes/node/install/envs/kubelet.sh
    - name: {{ pillar['rbd-path'] }}/etc/envs/kubelet.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-conf:
  file.managed:
    - source: salt://kubernetes/node/install/k8s/custom.conf
    - name: {{ pillar['rbd-path'] }}/kubernetes/k8s/custom.conf
    - makedirs: Ture
    - template: jinja

{% if "compute" in grains['id'] %}
kubelet-ssl-rsync:
  file.recurse:
    - source: salt://kubernetes/server/install/ssl
    - name: {{ pillar['rbd-path'] }}/kubernetes/ssl

kubelet-cfg-rsync:
  file.recurse:
    - source: salt://kubernetes/server/install/kubecfg
    - name: {{ pillar['rbd-path'] }}/kubernetes/kubecfg

{% endif %}

kubelet-cni:
  file.recurse:
    - source: salt://kubernetes/node/install/cni
    - name: {{ pillar['rbd-path'] }}/cni/net.d
    - template: jinja
    - makedirs: Ture

kubelet-cni-bin:
  file.recurse:
    - source: salt://misc/file/cni/bin
    - name: {{ pillar['rbd-path'] }}/cni/bin
    - file_mode: '0755'
    - user: root
    - group: root
    - makedirs: Ture

/etc/systemd/system/kubelet.service:
  file.managed:
    - source: salt://kubernetes/node/install/systemd/kubelet.service
    - template: jinja

cp-bin-kubelet:
  file.managed:
    - source: salt://misc/file/bin/kubelet
    - name: /usr/local/bin/kubelet
    - mode: 755

/usr/bin/kubelet:
  file.managed:
    - source: /usr/local/bin/kubelet
    - mode: 755
    - user: root

{% if grains['id'] == 'manage01' %}

pull-pause-img:
  cmd.run:
    - name: docker pull rainbond/pause-amd64:3.0
    - unless: docker inspect rainbond/pause-amd64:3.0

rename-pause-img:
  cmd.run: 
    - name: docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
    - unless: docker inspect goodrain.me/pause-amd64:3.0
    - require:
      - cmd: pull-pause-img
{% else %}
pull-pause-img:
  cmd.run:
    - name: docker pull goodrain.me/pause-amd64:3.0
    - unless: docker inspect goodrain.me/pause-amd64:3.0
{% endif %}

kubelet:
  service.running:
    - enable: True
    - watch:
      - file: kubelet-env
      - file: kubelet-cni
{% if grains['id'] == 'manage01' %}
      - cmd: rename-pause-img
{% endif %}
    - require:
      - file: kubelet-env
      - file: kubelet-cni
      - cmd: pull-pause-img
{% if grains['id'] == 'manage01' %}
      - cmd: rename-pause-img
{% endif %}