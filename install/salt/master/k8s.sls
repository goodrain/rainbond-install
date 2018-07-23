k8s-conf:
  file.managed:
    - source: salt://install/files/k8s/custom.conf
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/custom.conf
    - makedirs: True
    - template: jinja

kube-cfg-rsync-grdata:
  file.recurse:
    - source: salt://kubernetes/server/install/kubecfg
    - name: /grdata/services/k8s/kubecfg
    - makedirs: True

kube-ssl-rsync-grdata:
  file.recurse:
    - source: salt://kubernetes/server/install/ssl
    - name: /grdata/services/k8s/ssl
    - makedirs: True

kube-local:
  file.managed:
    - source: {{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg/admin.kubeconfig
    - name: /root/.kube/config
    - makedirs: True
    - mode: 600
    - user: root
    - group: root