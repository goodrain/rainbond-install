{% if grains['os_family']|lower == 'redhat' %}
DOCKER_OPTS="-H unix:///var/run/docker.sock -H 127.0.0.1:2376 --bip=172.30.42.1/16 --dns={{pillar['master-private-ip']}} --insecure-registry goodrain.me --storage-driver=devicemapper --storage-opt dm.xfs_nospace_max_retries=0 --userland-proxy=false"
{% else %}
DOCKER_OPTS="-H unix:///var/run/docker.sock -H 127.0.0.1:2376 --bip=172.30.42.1/16 --dns={{pillar['master-private-ip']}} --insecure-registry goodrain.me --userland-proxy=false"
{% endif %}
