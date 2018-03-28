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
    - source: salt://kubernetes/node/install/env/kubelet.sh
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

node-rsync:
  file.managed:
    - source: salt://kubernetes/node/install/run/rsync.sh
    - name: /tmp/node_rsync.sh
    - template: jinja
  cmd.run:
    - name: bash /tmp/node_rsync.sh

kubelet-cni:
  file.recurse:
    - source: salt://kubernetes/node/install/cni
    - name: {{ pillar['rbd-path'] }}/cni/net.d
    - template: jinja
    - makedirs: Ture

/etc/systemd/system/kubelet.service:
  file.managed:
    - source: salt://kubernetes/node/install/systemd/kubelet.service
    - template: jinja

/usr/bin/kubelet:
  file.managed:
    - source: /usr/local/bin/kubelet
    - mode: 755
    - user: root

image-pull:
  cmd.run: 
    - name: docker pull rainbond/pause-amd64:3.0 && docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
    - unless: docker pull goodrain.me/pause-amd64:3.0

kubelet:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kubelet.sh
      - file: {{ pillar['rbd-path'] }}/cni/net.d
      - cmd: image-pull

