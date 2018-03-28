pull_cfssl_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.master.get('cfssl_image', 'rainbond/cfssl') }}

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v {{ pillar['rbd-path'] }}/kubernetes/ssl:/ssl -w /ssl {{ pillar.kubernetes.master.get('cfssl_image', 'rainbond/cfssl') }}
    - unless: ls {{ pillar['rbd-path'] }}/kubernetes/ssl

pull_kubecfg_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.master.get('kubecfg_image', 'rainbond/kubecfg') }}

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v {{ pillar['rbd-path'] }}/kubernetes/ssl:/etc/goodrain/kubernetes/ssl -v {{ pillar['rbd-path'] }}/kubernetes/kubecfg:/k8s {{ pillar.kubernetes.master.get('kubecfg_image', 'rainbond/kubecfg') }}

pull_api_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.master.get('api_image','rainbond/kube-apiserver:v1.6.4') }}

pull_manager_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.master.get('manager','rainbond/kube-controller-manager:v1.6.4') }}

pull_schedule_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.master.get('schedule','rainbond/kube-scheduler:v1.6.4') }}

k8s_envs:
  file.managed:
    - source:
      - salt://kubernetes/master/install/envs/api.sh
    - name: {{ pillar['rbd-path'] }}/etc/envs/kube-apiserver.sh
    - template: jinja
    - user: root
    - group: root

k8s-api-script:
  file.managed:
    - source: salt://kubernetes/master/install/scripts/start-kube-apiserver.sh
    - name: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kube-apiserver.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-manager-script:
  file.managed:
    - source: salt://kubernetes/master/install/scripts/start-kube-controller-manager.sh
    - name: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kube-controller-manager.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-scheduler-script:
  file.managed:
    - source: salt://kubernetes/master/install/scripts/start-kube-scheduler.sh
    - name: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kube-scheduler.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-conf:
  file.managed:
    - source: salt://kubernetes/master/install/k8s/custom.conf
    - name: {{ pillar['rbd-path'] }}/kubernetes/k8s/custom.conf
    - makedirs: Ture
    - template: jinja

/etc/systemd/system:
  file.recurse:
    - source:
      - salt://kubernetes/master/install/systemd
    - template: jinja
    - user: root
    - group: root

kube-apiserver:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kube-apiserver.sh
      - cmd: pull_api_image

kube-controller-manager:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kube-controller-manager.sh
      - cmd: pull_manager_image

kube-scheduler:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['rbd-path'] }}/kubernetes/scripts/start-kube-scheduler.sh
      - cmd: pull_schedule_image

kube-local:
  file.managed:
    - source: {{ pillar['rbd-path'] }}/kubernetes/kubecfg/admin.kubeconfig
    - name: /root/.kube/config
    - makedirs: Ture
    - mode: 600
    - user: root
    - group: root