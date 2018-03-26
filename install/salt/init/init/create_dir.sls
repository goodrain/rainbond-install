{% for DIR in pillar['rbd-path'] %}
{{ DIR }}/rainbond/etc/cni:
  file.directory:
   - user: rain
   - group: rain
   - mode: 755
   - makedirs: Ture
   - recurse:
     - user
     - group
     - mode

{{ DIR }}/rainbond/etc/kubernetes:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/bin/cni:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/etcd/envs:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/etcd/scripts:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/docker/envs:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/docker/scripts:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/rbd-lb:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/rbd-proxy:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/rbd-db:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/rbd-chaos/ssh:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/prometheus:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/rbd-slogger:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/goodrain_node/scripts:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/goodrain_node/envs:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/calico/scripts:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/calico/envs:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/k8s/scripts:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/etc/k8s/envs:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/cache/build:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/cache/source:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/logs/docker_logs:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/logs/service_logs/goodrain_web:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/logs/service_logs/rbd-lb:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/logs/service_logs/webcli:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/logs/service_logs/labor:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/logs/service_logs/openrestry:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/logs/service_logs/rbd-api:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/data/rbd-db:
  file.directory:
   - makedirs: Ture

{{ DIR }}/rainbond/data/etcd:
  file.directory:
   - makedirs: Ture
{% endfor %}


/grdata:
  file.directory:
   - user: rain
   - group: rain
   - mode: 755
   - makedirs: Ture
   - recurse:
     - user
     - group
     - mode




