{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

kubelet-script:
  file.managed:
    - source: salt://kubernetes/node/install/scripts/start-kubelet.sh
    - name: {{ pillar['rbd-path'] }}/scripts/start-kubelet.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

kubelet-env:
  file.managed:
    - source: salt://kubernetes/node/install/envs/kubelet.sh
    - name: {{ pillar['rbd-path'] }}/envs/kubelet.sh
    - makedirs: True
    - template: jinja
    - mode: 755
    - user: root
    - group: root

k8s-custom-conf:
  file.managed:
    - source: salt://kubernetes/node/install/custom.conf
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/custom.conf
    - makedirs: True
    - template: jinja

kubelet-ssl-rsync:
  file.recurse:
    - source: salt://kubernetes/server/install/ssl
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/ssl

kubelet-cfg-rsync:
  file.recurse:
    - source: salt://kubernetes/server/install/kubecfg
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg

kubelet-cni:
  file.recurse:
    - source: salt://kubernetes/node/install/cni
    - name: {{ pillar['rbd-path'] }}/etc/cni/
    - template: jinja
    - makedirs: True

kubelet-cni-bin:
  file.recurse:
    - source: salt://misc/file/cni/bin
    - name: {{ pillar['rbd-path'] }}/bin
    - file_mode: '0755'
    - user: root
    - group: root
    - makedirs: True

/etc/systemd/system/kubelet.service:
  file.managed:
    - source: salt://kubernetes/node/install/systemd/kubelet.service
    - template: jinja

/usr/local/bin/kubelet:
  file.managed:
    - source: salt://misc/file/bin/kubelet
    - mode: 755

{% if grains['id'] == 'manage01' %}

pull-pause-img:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ PAUSEIMG }}_{{ PAUSEVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}

rename-pause-img:
  cmd.run: 
    - name: docker tag {{PUBDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }} {{PRIDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}
    - require:
      - cmd: pull-pause-img
{% else %}
pull-pause-img:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PRIDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}
  {% else %}
    -name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PRIDOMAIN}}_{{ PAUSEIMG }}_{{ PAUSEVER }}.gz
  {% endif %}
    - unless: docker inspect {{PRIDOMAIN}}/{{ PAUSEIMG }}:{{ PAUSEVER }}
{% endif %}

kubelet:
  service.running:
    - enable: True
    - watch:
      - file: kubelet-env
      - file: k8s-custom-conf
      - file: kubelet-cni
      - file: kubelet-ssl-rsync
      - file: kubelet-cfg-rsync
      - file: kubelet-script
{% if grains['id'] == 'manage01' %}
      - cmd: rename-pause-img
{% endif %}
    - require:
      - file: kubelet-env
      - file: k8s-custom-conf
      - file: kubelet-cni
      - file: kubelet-ssl-rsync
      - file: kubelet-cfg-rsync
      - cmd: pull-pause-img
{% if grains['id'] == 'manage01' %}
      - cmd: rename-pause-img
{% endif %}