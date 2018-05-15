{% if grains['os_family']|lower == 'redhat' and grains['osrelease_info'][1] == 4 %}
DOCKER_OPTS="-H unix:///var/run/docker.sock --bip=172.30.42.1/16 --insecure-registry goodrain.me --storage-driver=devicemapper --userland-proxy=false --dns-opt=use-vc"
{% else %}
DOCKER_OPTS="-H unix:///var/run/docker.sock --bip=172.30.42.1/16 --insecure-registry goodrain.me --storage-driver=devicemapper --userland-proxy=false"
{% endif %}
