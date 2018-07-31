k8s-conf:
  file.managed:
    - source: salt://install/files/k8s/custom.conf
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/custom.conf
    - makedirs: True
    - template: jinja

kube-ssl-rsync:
  file.recurse:
    - source: salt://install/files/k8s/ssl
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/ssl

kube-cfg-rsync:
  file.recurse:
    - source: salt://install/files/k8s/kubecfg
    - name: {{ pillar['rbd-path'] }}/etc/kubernetes/kubecfg 

kube-cfg-rsync-grdata:
  file.recurse:
    - source: salt://install/files/k8s/kubecfg
    - name: /grdata/services/k8s/kubecfg
    - makedirs: True

kube-ssl-rsync-grdata:
  file.recurse:
    - source: salt://install/files/k8s/ssl
    - name: /grdata/services/k8s/ssl
    - makedirs: True

kube-local:
  file.managed:
    - source: salt://install/files/k8s/kubecfg/admin.kubeconfig
    - name: /root/.kube/config
    - makedirs: True
    - mode: 600
    - user: root
    - group: root