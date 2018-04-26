# grshell.action.stop

calico:
  service.dead

node:
  service.dead

#============== kubernetes ==============
kube-apiserver:
  service.dead

kube-scheduler:
  service.dead

kube-controller-manager:
  service.dead

kubelet:
  service.dead

#============== docker-compose ==============
stop-compose:
  cmd.run:
    - name: dc-compose stop 

clear-container:
  cmd.run:
    - name: cclear
    - require: 
      - cmd: stop-compose

etcd:
  service.dead

docker:
  service.dead