{% if grains['host'] == "manage01" %}
network_calico_cni:
  cmd.run:
    - name: cp -a /opt/cni/bin {{ pillar['rbd-path'] }}/cni/
    - require:
      - cmd: install_manage_ctl

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

{% endif %}