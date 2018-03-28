{% set DIR = salt['pillar.get']('rbd-path','/opt') %}
/rainbond/etc/cni:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/cni
    - user: rain 
    - group: rain
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/rainbond/bin/cni:
  file.directory:
    - name: {{ DIR }}/rainbond/bin/cni
    - makedirs: True

/rainbond/etc/etcd/envs:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/etcd/envs
    - makedirs: True

/rainbond/etc/etcd/scripts:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/etcd/scripts
    - makedirs: True

/rainbond/etc/docker/envs:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/docker/envs
    - makedirs: Ture

/rainbond/etc/docker/scripts:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/docker/scripts
    - makedirs: Ture

/rainbond/etc/rbd-lb:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/rbd-lb
    - makedirs: Ture

/rainbond/etc/rbd-proxy:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/rbd-proxy
    - makedirs: Ture

/rainbond/etc/rbd-db:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/rbd-db
    - makedirs: Ture

/rainbond/etc/rbd-chaos/ssh:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/rbd-chaos/ssh
    - makedirs: Ture

/rainbond/etc/prometheus:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/prometheus
    - makedirs: Ture

/rainbond/etc/rbd-slogger:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/rbd-slogger
    - makedirs: Ture

/rainbond/etc/goodrain_node/scripts:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/goodrain_node/scripts
    - makedirs: Ture

/rainbond/etc/goodrain_node/envs:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/goodrain_node/envs
    - makedirs: Ture

/rainbond/etc/calico/scripts:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/calico/scripts
    - makedirs: Ture

/rainbond/etc/calico/envs:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/calico/envs
    - makedirs: Ture

/rainbond/etc/k8s/scripts:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/k8s/scripts
    - makedirs: Ture

/rainbond/etc/k8s/envs:
  file.directory:
    - name: {{ DIR }}/rainbond/etc/k8s/envs
    - makedirs: Ture

/rainbond/cache/build:
  file.directory:
    - name: {{ DIR }}/rainbond/cache/build
    - makedirs: Ture

/rainbond/cache/source:
  file.directory:
    - name: {{ DIR }}/rainbond/cache/source
    - makedirs: Ture

/rainbond/logs/docker_logs:
  file.directory:
    - name: {{ DIR }}/rainbond/logs/docker_logs
    - makedirs: Ture

/rainbond/logs/service_logs/goodrain_web:
  file.directory:
    - name: {{ DIR }}/rainbond/logs/service_logs/goodrain_web
    - makedirs: Ture

/rainbond/logs/service_logs/rbd-lb:
  file.directory:
    - name: {{ DIR }}/rainbond/logs/service_logs/rbd-lb
    - makedirs: Ture

/rainbond/logs/service_logs/webcli:
  file.directory:
    - name: {{ DIR }}/rainbond/logs/service_logs/webcli
    - makedirs: Ture

/rainbond/logs/service_logs/labor:
  file.directory:
    - name: {{ DIR }}/rainbond/logs/service_logs/labor
    - makedirs: Ture

/rainbond/logs/service_logs/openrestry:
  file.directory:
    - name: {{ DIR }}/rainbond/logs/service_logs/openrestry
    - makedirs: Ture

/rainbond/logs/service_logs/rbd-api:
  file.directory:
    - name: {{ DIR }}/rainbond/logs/service_logs/rbd-api
    - makedirs: Ture

/rainbond/data/rbd-db:
 file.directory:
    - name: {{ DIR }}/rainbond/data/rbd-db
    - makedirs: Ture

/rainbond/data/etcd:
  file.directory:
    - name: /rainbond/data/etcd
    - makedirs: Ture


/grdata:
  file.directory:
   - name: /grdata
   - user: root
   - group: root
   - mode: 755
   - makedirs: Ture
   - recurse:
     - user
     - group
     - mode
#
#
#
#
