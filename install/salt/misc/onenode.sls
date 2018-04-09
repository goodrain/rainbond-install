pull_cfssl_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.server.get('cfssl_image', 'rainbond/cfssl') }}

check_or_create_certificates:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/ssl -w /ssl {{ pillar.kubernetes.server.get('cfssl_image', 'rainbond/cfssl') }}

pull_kubecfg_image:
  cmd.run:
    - name: docker pull {{ pillar.kubernetes.server.get('kubecfg_image', 'rainbond/kubecfg') }}

check_or_create_kubeconfig:
  cmd.run:
    - name: docker run --rm -v /srv/salt/kubernetes/server/install/ssl:/etc/goodrain/kubernetes/ssl -v /srv/salt/kubernetes/server/install/kubecfg:/k8s {{ pillar.kubernetes.server.get('kubecfg_image', 'rainbond/kubecfg') }}

rsync_kube-proxy_kubeconfig:
  file.directory:
    - name: /grdata/kubernetes
    - makedirs: True
  cmd.run:
    - name: cp -a /srv/salt/kubernetes/server/install/kubecfg/kube-proxy.kubeconfig /grdata/kubernetes/kube-proxy.kubeconfig

prepare_cli_tools:
  cmd.run:
    - name: docker run --rm -v /srv/salt/misc/file:/sysdir {{ pillar.get('cli-image', 'rainbond/static:allcli_v3.5') }} tar zxf /pkg.tgz -C /sysdir


{% if pillar.domain is defined %}
compose_file:
  file.managed:
     - source: salt://init/files/docker-compose.yaml
     - name: {{ pillar['rbd-path'] }}/docker-compose.yaml
     - makedirs: Ture
     - template: jinja
{% endif %}
