proxy_kubeconfig:
  file.managed:
     - source: salt://kubernetes/server/install/kubecfg/kube-proxy.kubeconfig
     - name: /grdata/kubernetes/kube-proxy.kubeconfig
     - unless: ls /grdata/kubernetes/kube-proxy.kubeconfig
     - makedirs: True