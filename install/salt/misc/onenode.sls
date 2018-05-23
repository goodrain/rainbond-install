{% set CFSSLIMG = salt['pillar.get']('kubernetes:cfssl:image') -%}
{% set CFSSLVER = salt['pillar.get']('kubernetes:cfssl:version') -%}

pull_cfssl_image:
  cmd.run:
    - name: docker pull {{ CFSSLIMG }}:{{ CFSSLVER }}
    - unless: docker inspect {{ CFSSLIMG }}:{{ CFSSLVER }}

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/ssl -w /ssl {{ CFSSLIMG }}:{{ CFSSLVER }} kip {{ pillar['master-private-ip'] }}
    - unless:
      - ls /srv/salt/kubernetes/server/install/ssl/*.pem
      - ls /srv/salt/kubernetes/server/install/ssl/*.csr
    - require:
      - cmd: pull_cfssl_image

{% set KUBECFGIMG = salt['pillar.get']('kubernetes:kubecfg:image') -%}
{% set KUBECFGVER = salt['pillar.get']('kubernetes:kubecfg:version') -%}
pull_kubecfg_image:
  cmd.run:
    - name: docker pull {{ KUBECFGIMG }}:{{ KUBECFGVER }}
    - unless: docker inspect {{ KUBECFGIMG }}:{{ KUBECFGVER }}

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/etc/goodrain/kubernetes/ssl -v /srv/salt/kubernetes/server/install/kubecfg:/k8s {{ KUBECFGIMG }}:{{ KUBECFGVER }}
    - unless: ls /srv/salt/kubernetes/server/install/kubecfg/*.kubeconfig
    - require:
      - cmd: pull_kubecfg_image

rsync_kube-proxy_kubeconfig:
  file.directory:
    - name: /grdata/kubernetes
    - makedirs: True
  cmd.run:
    - name: cp -a /srv/salt/kubernetes/server/install/kubecfg/kube-proxy.kubeconfig /grdata/kubernetes/kube-proxy.kubeconfig
    - unless: ls /grdata/kubernetes/kube-proxy.kubeconfig
    - require:
      - cmd: check_or_create_kubeconfig

{% set CLIIMG = salt['pillar.get']('kubernetes:static:image') -%}
{% set CLIVER = salt['pillar.get']('kubernetes:static:version') -%}
pull_static_image:
  cmd.run:
<<<<<<< HEAD
    - name: docker pull {{ pillar.get('cli-image', 'rainbond/static:allcli_v3.6') }}
    - unless: docker inspect rainbond/static:allcli_v3.6

prepare_cli_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{ pillar.get('cli-image', 'rainbond/static:allcli_v3.6') }} tar zxf /pkg.tgz -C /sysdir
=======
    - name: docker pull {{ CLIIMG }}:{{ CLIVER }}
    - unless: docker inspect {{ CLIIMG }}:{{ CLIVER }}

prepare_cli_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{ CLIIMG }}:{{ CLIVER }} tar zxf /pkg.tgz -C /sysdir
>>>>>>> reconsitution
    - require:
      - cmd: pull_static_image
    - unless:
      - test -f /srv/salt/misc/file/bin/calicoctl
      - test -f /srv/salt/misc/file/bin/docker-compose
      - test -f /srv/salt/misc/file/bin/etcdctl
      - test -f /srv/salt/misc/file/bin/grctl
      - test -f /srv/salt/misc/file/bin/kubectl
      - test -f /srv/salt/misc/file/bin/kubelet
      - test -f /srv/salt/misc/file/bin/node
      - test -f /srv/salt/misc/file/cni/bin/calico
      - test -f /srv/salt/misc/file/cni/bin/calico-ipam
      - test -f /srv/salt/misc/file/cni/bin/loopback

{% if pillar.domain is defined %}
compose_file:
  file.managed:
     - source: salt://misc/files/docker-compose.yaml
     - name: {{ pillar['rbd-path'] }}/docker-compose.yaml
     - makedirs: Ture
     - template: jinja
{% endif %}