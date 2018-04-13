pull_cfssl_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.server.get('cfssl_image', 'rainbond/cfssl:dev') }}
    - unless: docker inspect rainbond/cfssl:dev

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/ssl -w /ssl {{ pillar.kubernetes.server.get('cfssl_image', 'rainbond/cfssl:dev') }} kip {{ pillar['inet-ip'] }}
    - unless:
      - ls /srv/salt/kubernetes/server/install/ssl/*.pem
      - ls /srv/salt/kubernetes/server/install/ssl/*.csr
    - require:
      - cmd: pull_cfssl_image

pull_kubecfg_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.server.get('kubecfg_image', 'rainbond/kubecfg:dev') }}
    - unless: docker inspect rainbond/kubecfg:dev

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/etc/goodrain/kubernetes/ssl -v /srv/salt/kubernetes/server/install/kubecfg:/k8s {{ pillar.kubernetes.server.get('kubecfg_image', 'rainbond/kubecfg:dev') }}
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

pull_static_image:
  cmd.run:
    - name: docker pull {{ pillar.get('cli-image', 'rainbond/static:allcli_v3.5') }}
    - unless: docker inspect rainbond/static:allcli_v3.5

prepare_cli_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{ pillar.get('cli-image', 'rainbond/static:allcli_v3.5') }} tar zxf /pkg.tgz -C /sysdir
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
     - source: salt://init/files/docker-compose.yaml
     - name: {{ pillar['rbd-path'] }}/docker-compose.yaml
     - makedirs: Ture
     - template: jinja
{% endif %}