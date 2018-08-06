{% if "manage" in grains['id'] %}
{% if pillar.domain is defined %}
compose_base_file:
  file.managed:
     - source: salt://install/files/tpl/base.yaml
     - name: {{ pillar['rbd-path'] }}/compose/base.yaml
     - makedirs: True
     - template: jinja
compose_lb_file:
  file.managed:
     - source: salt://install/files/tpl/lb.yaml
     - name: {{ pillar['rbd-path'] }}/compose/lb.yaml
     - makedirs: True
     - template: jinja
compose_ui_file:
  file.managed:
     - source: salt://install/files/tpl/ui.yaml
     - name: {{ pillar['rbd-path'] }}/compose/ui.yaml
     - makedirs: True
     - template: jinja
compose_plugin_file:
  file.managed:
     - source: salt://install/files/tpl/plugin.yaml
     - name: {{ pillar['rbd-path'] }}/compose/plugin.yaml
     - makedirs: True
     - template: jinja
{% endif %}
{% endif %}

{% set CFSSLIMG = salt['pillar.get']('kubernetes:cfssl:image') -%}
{% set CFSSLVER = salt['pillar.get']('kubernetes:cfssl:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}
{% set K8SCNIIMG = salt['pillar.get']('kubernetes:cni:image') -%}
{% set K8SCNIVER = salt['pillar.get']('kubernetes:cni:version') -%}
{% set KUBECFGIMG = salt['pillar.get']('kubernetes:kubecfg:image') -%}
{% set KUBECFGVER = salt['pillar.get']('kubernetes:kubecfg:version') -%}
{% set RBDCNIIMG = salt['pillar.get']('rainbond-modules:rbd-cni:image') -%}
{% set RBDCNIVER = salt['pillar.get']('rainbond-modules:rbd-cni:version') -%}
{% set KUBECFGIMG = salt['pillar.get']('kubernetes:kubecfg:image') -%}
{% set KUBECFGVER = salt['pillar.get']('kubernetes:kubecfg:version') -%}

{% if grains['id'] == "manage01" %}
docker_load_rbd-cni:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ RBDCNIIMG }}_{{ RBDCNIVER }}.gz

docker_load_k8s-cni:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ K8SCNIIMG }}_{{ K8SCNIVER }}.gz

docker_load_cfssl:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ CFSSLIMG }}_{{ CFSSLVER }}.gz

docker_load_kubecfg:
  cmd.run:
    - name: docker load -i {{ pillar['rbd-path'] }}/install/install/imgs/goodrainme_{{ KUBECFGIMG }}_{{ KUBECFGVER }}.gz

prepare_rbd_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/install/files/misc:/sysdir {{PRIDOMAIN}}/{{ RBDCNIIMG }}:{{ RBDCNIVER }} tar zxf /pkg.tgz -C /sysdir

prepare_k8s_cni_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/install/files/misc:/sysdir {{PRIDOMAIN}}/{{ K8SCNIIMG }}:{{ K8SCNIVER }} tar zxf /pkg.tgz -C /sysdir

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v /srv/salt/install/files/k8s/ssl:/ssl -w /ssl {{PRIDOMAIN}}/{{ CFSSLIMG }}:{{ CFSSLVER }} kip {{ pillar['master-private-ip'] }}
    - unless: ls /srv/salt/install/files/k8s/ssl/*.pem

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v /srv/salt/install/files/k8s/ssl:/etc/goodrain/kubernetes/ssl -v /srv/salt/install/files/k8s/kubecfg:/k8s {{PRIDOMAIN}}/{{ KUBECFGIMG }}:{{ KUBECFGVER }}
    - unless: ls /srv/salt/install/files/k8s/kubecfg/*.kubeconfig

proxy_kubeconfig:
  file.managed:
     - source: salt://install/files/k8s/kubecfg/kube-proxy.kubeconfig
     - name: /grdata/kubernetes/kube-proxy.kubeconfig
     - makedirs: True

update_sql:
  file.managed:
    - source: salt://install/files/plugins/init.sql
    - name: /tmp/init.sql
    - template: jinja
  
update_sql_sh:
  file.managed:
    - source: salt://install/files/plugins/init.sh
    - name: /tmp/init.sh
    - template: jinja
{% endif %}

#==================== init lb ====================
default_http_conf:
  file.managed:
    - source: salt://install/files/plugins/proxy.conf
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_servers/default.http.conf
    - template: jinja
    - makedirs: True

proxy_site_ssl:
  file.recurse:
    - source: salt://install/files/ssl/goodrain.me
    - name: {{ pillar['rbd-path'] }}/etc/rbd-lb/dynamics/dynamic_certs/goodrain.me
    - makedirs: True

/usr/local/bin/calicoctl:
  file.managed:
    - source: salt://install/files/misc/bin/calicoctl
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/docker-compose:
  file.managed:
    - source: salt://install/files/misc/bin/docker-compose
    - mode: 755
    - user: root
    - group: root

{% if "manage" in grains['id'] %}
/usr/local/bin/grcert:
  file.managed:
    - source: salt://install/files/misc/bin/grcert
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/grctl:
  file.managed:
    - source: salt://install/files/misc/bin/grctl
    - mode: 755
    - user: root
    - group: root

{% if grains['id'] == "manage01"  %}
/usr/local/bin/domain-cli:
  file.managed:
    - source: salt://install/files/misc/bin/domain-cli
    - mode: 755
    - user: root
    - group: root
{% endif %}
{% endif %}

/usr/local/bin/kubectl:
  file.managed:
    - source: salt://install/files/misc/bin/kubectl
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/etcdctl:
  file.managed:
    - source: salt://install/files/misc/bin/etcdctl
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/kubelet:
  file.managed:
    - source: salt://install/files/misc/bin/kubelet
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/node:
  file.managed:
    - source: salt://install/files/misc/bin/node
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/ctop:
  file.managed:
    - source: salt://install/files/misc/bin/ctop
    - mode: 755
    - user: root
    - group: root

/usr/local/bin/yq:
  file.managed:
    - source: salt://install/files/misc/bin/yq
    - mode: 755
    - user: root
    - group: root