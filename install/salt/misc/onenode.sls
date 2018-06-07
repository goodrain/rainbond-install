{% set CFSSLIMG = salt['pillar.get']('kubernetes:cfssl:image') -%}
{% set CFSSLVER = salt['pillar.get']('kubernetes:cfssl:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

pull_cfssl_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ CFSSLIMG }}_{{ CFSSLVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }}

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/ssl -w /ssl {{PUBDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }} kip {{ pillar['master-private-ip'] }}
    - unless:
      - ls /srv/salt/kubernetes/server/install/ssl/*.pem
      - ls /srv/salt/kubernetes/server/install/ssl/*.csr
    - require:
      - cmd: pull_cfssl_image

{% set KUBECFGIMG = salt['pillar.get']('kubernetes:kubecfg:image') -%}
{% set KUBECFGVER = salt['pillar.get']('kubernetes:kubecfg:version') -%}
pull_kubecfg_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ KUBECFGIMG }}_{{ KUBECFGVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/etc/goodrain/kubernetes/ssl -v /srv/salt/kubernetes/server/install/kubecfg:/k8s {{PUBDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}
    - unless: ls /srv/salt/kubernetes/server/install/kubecfg/*.kubeconfig
    - require:
      - cmd: pull_kubecfg_image

{% set K8SCNIIMG = salt['pillar.get']('kubernetes:cni:image') -%}
{% set K8SCNIVER = salt['pillar.get']('kubernetes:cni:version') -%}
pull_k8s_cni_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ K8SCNIIMG }}_{{ K8SCNIVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }}

prepare_k8s_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{PUBDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }} tar zxf /pkg.tgz -C /sysdir
    - require:
      - cmd: pull_k8s_cni_image
    - unless:
      - test -f /srv/salt/misc/file/bin/calicoctl
      - test -f /srv/salt/misc/file/bin/docker-compose
      - test -f /srv/salt/misc/file/bin/etcdctl
      - test -f /srv/salt/misc/file/bin/kubectl
      - test -f /srv/salt/misc/file/bin/kubelet
      - test -f /srv/salt/misc/file/cni/bin/calico
      - test -f /srv/salt/misc/file/cni/bin/calico-ipam
      - test -f /srv/salt/misc/file/cni/bin/loopback

{% set RBDCNIIMG = salt['pillar.get']('rainbond-modules:rbd-cni:image') -%}
{% set RBDCNIVER = salt['pillar.get']('rainbond-modules:rbd-cni:version') -%}
pull_rbd_cni_image:
  cmd.run:
  {% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }}
  {% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ RBDCNIIMG }}_{{ RBDCNIVER }}.gz
  {% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }}
prepare_rbd_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{PUBDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }} tar zxf /pkg.tgz -C /sysdir
    - require: 
      - cmd: pull_rbd_cni_image
{% if pillar.domain is defined %}
compose_file:
  file.managed:
     - source: salt://misc/files/docker-compose.yaml
     - name: {{ pillar['rbd-path'] }}/docker-compose.yaml
     - makedirs: True
     - template: jinja
{% endif %}