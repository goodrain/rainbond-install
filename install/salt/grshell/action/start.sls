# grshell.action.start

docker:
  service.running

etcd:
  service.running:
    - require:
      - service: docker

calico:
  service.running:
    - require:
      - service: etcd

node:
  service.running:
    - require:
      - service: etcd

#============== kubernetes ==============
kube-apiserver:
  service.running:
    - require:
      - service: etcd

kube-scheduler:
  service.running:
    - require:
      - service: kube-apiserver

kube-controller-manager:
  service.running:
    - require:
      - service: kube-apiserver

kubelet:
  service.running:
    - require:
      - service: kube-apiserver

#============== docker-compose ==============
stop-compose:
  cmd.run:
    - name: dc-compose up -d 
    - require: 
      - cmd: clear-container

clear-container:
  cmd.run:
    - name: cclear
    - require: 
      - service: docker