kubernetes:
  master:
    cfssl_image: rainbond/cfssl
    kubecfg_image: rainbond/kubecfg
    api_image: rainbond/kube-apiserver:v1.6.4
    manager: rainbond/kube-controller-manager:v1.6.4
    schedule: rainbond/kube-scheduler:v1.6.4
