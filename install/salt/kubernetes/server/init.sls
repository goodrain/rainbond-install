{% set APIIMG = salt['pillar.get']('kubernetes:api:image') -%}
{% set APIVER = salt['pillar.get']('kubernetes:api:version') -%}
{% set CTLMGEIMG = salt['pillar.get']('kubernetes:manager:image') -%}
{% set CTLMGEVER = salt['pillar.get']('kubernetes:manager:version') -%}
{% set SDLIMG = salt['pillar.get']('kubernetes:schedule:image') -%}
{% set SDLVER = salt['pillar.get']('kubernetes:schedule:version') -%}

pull_api_image:
  cmd.run:
    - name: docker pull {{ APIIMG }}:{{ APIVER }}
    - unless: docker inspect {{ APIIMG }}:{{ APIVER }}

pull_manager_image:
  cmd.run:
    - name: docker pull {{ CTLMGEIMG }}:{{ APIVER }}
    - unless: docker inspect {{ CTLMGEIMG }}:{{ APIVER }}

pull_schedule_image:
  cmd.run:
    - name: docker pull {{ SDLIMG }}:{{ SDLVER }}
    - unless: docker inspect {{ SDLIMG }}:{{ SDLVER }}

k8s-api-script:
  file.managed:
    - source: salt://kubernetes/server/install/scripts/start-kube-apiserver.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-kube-apiserver.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-manager-script:
  file.managed:
    - source: salt://kubernetes/server/install/scripts/start-kube-controller-manager.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-kube-controller-manager.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-scheduler-script:
  file.managed:
    - source: salt://kubernetes/server/install/scripts/start-kube-scheduler.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-kube-scheduler.sh
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-conf:
  file.managed:
    - source: salt://kubernetes/server/install/custom.conf
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/custom.conf
    - makedirs: Ture
    - template: jinja

/etc/systemd/system:
  file.recurse:
    - source: salt://kubernetes/server/install/systemd
    - template: jinja
    - user: root
    - group: root

kube-ssl-rsync:
  file.recurse:
    - source: salt://kubernetes/server/install/ssl
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/ssl

kube-cfg-rsync-grdata:
  file.recurse:
    - source: salt://kubernetes/server/install/kubecfg
    - name: /grdata/services/k8s/kubecfg
    - makedirs: Ture

kube-ssl-rsync-grdata:
  file.recurse:
    - source: salt://kubernetes/server/install/ssl
    - name: /grdata/services/k8s/ssl
    - makedirs: Ture


kube-cfg-rsync:
  file.recurse:
    - source: salt://kubernetes/server/install/kubecfg
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg 

kube-apiserver:
  service.running:
    - enable: True
    - watch:
      - file: k8s-conf
      - file: kube-ssl-rsync
      - file: kube-cfg-rsync
      - file: k8s-api-script
      - cmd: pull_api_image
    - require:
      - file: k8s-conf
      - file: kube-ssl-rsync
      - file: kube-cfg-rsync
      - file: k8s-api-script
      - cmd: pull_api_image

kube-controller-manager:
  service.running:
    - enable: True
    - watch:
      - file: k8s-conf
      - file: kube-ssl-rsync
      - file: kube-cfg-rsync
      - file: k8s-manager-script
      - cmd: pull_manager_image
    - require:
      - file: k8s-conf
      - file: kube-ssl-rsync
      - file: kube-cfg-rsync
      - file: k8s-manager-script
      - cmd: pull_manager_image


kube-scheduler:
  service.running:
    - enable: True
    - watch:
      - file: k8s-conf
      - file: kube-ssl-rsync
      - file: kube-cfg-rsync
      - file: k8s-scheduler-script
      - cmd: pull_schedule_image
    - require:
      - file: k8s-conf
      - file: kube-ssl-rsync
      - file: kube-cfg-rsync
      - file: k8s-scheduler-script
      - cmd: pull_schedule_image

kube-local:
  file.managed:
    - source: {{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg/admin.kubeconfig
    - name: /root/.kube/config
    - makedirs: Ture
    - mode: 600
    - user: root
    - group: root