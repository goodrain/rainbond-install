{% if grains['os_family']|lower == 'redhat' and grains['osrelease_info'][1] == 4 %}
DOCKER_OPTS="-H unix:///var/run/docker.sock --bip=172.30.42.1/16 --dns={{pillar['master-private-ip']}} --insecure-registry goodrain.me --storage-driver=devicemapper --storage-opt dm.fs=ext4 --userland-proxy=false --dns-opt=use-vc"
{% else %}
DOCKER_OPTS="-H unix:///var/run/docker.sock --bip=172.30.42.1/16 --dns={{pillar['master-private-ip']}} --insecure-registry goodrain.me --storage-driver=devicemapper --storage-opt dm.fs=ext4 --userland-proxy=false"
{% endif %}
