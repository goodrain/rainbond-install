kubernetes:
  server:
    cfssl_image: rainbond/cfssl:dev
    kubecfg_image: rainbond/kubecfg:dev
    api_image: rainbond/kube-apiserver:v1.6.4
    manager: rainbond/kube-controller-manager:v1.6.4
    schedule: rainbond/kube-scheduler:v1.6.4
