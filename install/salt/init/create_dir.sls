{% set DIR = salt['pillar.get']('rbd-path','/opt/rainbond') %}
/rainbond/etc/cni:
  file.directory:
    - name: {{ DIR }}/etc/cni
    - user: rain 
    - group: rain
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

/rainbond/cni:
  file.directory:
    - name: {{ DIR }}/cni
    - makedirs: True

/rainbond/etc/etcd/envs:
  file.directory:
    - name: {{ DIR }}/etc/etcd/envs
    - makedirs: True

/rainbond/etc/etcd/scripts:
  file.directory:
    - name: {{ DIR }}/etc/etcd/scripts
    - makedirs: True

/rainbond/etc/docker/envs:
  file.directory:
    - name: {{ DIR }}/etc/docker/envs
    - makedirs: Ture

/rainbond/etc/docker/scripts:
  file.directory:
    - name: {{ DIR }}/etc/docker/scripts
    - makedirs: Ture

/rainbond/etc/rbd-lb:
  file.directory:
    - name: {{ DIR }}/etc/rbd-lb
    - makedirs: Ture

/rainbond/etc/rbd-proxy:
  file.directory:
    - name: {{ DIR }}/etc/rbd-proxy
    - makedirs: Ture

/rainbond/etc/rbd-db:
  file.directory:
    - name: {{ DIR }}/etc/rbd-db
    - makedirs: Ture

/rainbond/etc/rbd-chaos/ssh:
  file.directory:
    - name: {{ DIR }}/etc/rbd-chaos/ssh
    - makedirs: Ture

/rainbond/etc/prometheus:
  file.directory:
    - name: {{ DIR }}/etc/prometheus
    - makedirs: Ture

/rainbond/etc/node/scripts:
  file.directory:
    - name: {{ DIR }}/etc/node/scripts
    - makedirs: Ture

/rainbond/etc/calico/scripts:
  file.directory:
    - name: {{ DIR }}/etc/calico/scripts
    - makedirs: Ture

/rainbond/etc/calico/envs:
  file.directory:
    - name: {{ DIR }}/etc/calico/envs
    - makedirs: Ture

/rainbond/etc/k8s/scripts:
  file.directory:
    - name: {{ DIR }}/etc/k8s/scripts
    - makedirs: Ture

/rainbond/etc/k8s/envs:
  file.directory:
    - name: {{ DIR }}/etc/k8s/envs
    - makedirs: Ture

/rainbond/cache/build:
  file.directory:
    - name: {{ DIR }}/cache/build
    - makedirs: Ture

/rainbond/cache/source:
  file.directory:
    - name: {{ DIR }}/cache/source
    - makedirs: Ture

/rainbond/logs/docker_logs:
  file.directory:
    - name: {{ DIR }}/logs/docker_logs
    - makedirs: Ture

/rainbond/logs/service_logs/goodrain_web:
  file.directory:
    - name: {{ DIR }}/logs/service_logs/goodrain_web
    - makedirs: Ture

/rainbond/logs/service_logs/rbd-lb:
  file.directory:
    - name: {{ DIR }}/logs/service_logs/rbd-lb
    - makedirs: Ture

/rainbond/logs/service_logs/webcli:
  file.directory:
    - name: {{ DIR }}/logs/service_logs/webcli
    - makedirs: Ture

/rainbond/logs/service_logs/labor:
  file.directory:
    - name: {{ DIR }}/logs/service_logs/labor
    - makedirs: Ture

/rainbond/logs/service_logs/openrestry:
  file.directory:
    - name: {{ DIR }}/logs/service_logs/openrestry
    - makedirs: Ture

/rainbond/logs/service_logs/rbd-api:
  file.directory:
    - name: {{ DIR }}/logs/service_logs/rbd-api
    - makedirs: Ture

/rainbond/data/rbd-db:
 file.directory:
    - name: {{ DIR }}/data/rbd-db
    - makedirs: Ture

/rainbond/data/etcd:
  file.directory:
    - name: {{ DIR }}/data/etcd
    - makedirs: Ture


/grdata:
  file.directory:
   - name: /grdata
   - mode: 755
   - makedirs: Ture