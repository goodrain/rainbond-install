dps:
    cmd.run:
      - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-docker-utils
      - unless: which dps

install-docker-compose:
  file.managed:
    - name: /usr/local/bin/dc-compose
    - source: salt://docker/envs/dc-compose
    - makedirs: Ture
    - template: jinja
    - mode: 755
    - user: root
    - group: root


{% if grains['host'] == "manage01" %}
make_domain_prepare:
  cmd.run:
    - name: echo "" > {{ pillar['rbd-path'] }}/.domain.log
    - unless: grep "goodrain" {{ pillar['rbd-path'] }}/.domain.log

make_domain:
  cmd.run:
    - name: docker run  --rm -v {{ pillar['rbd-path'] }}/.domain.log:/tmp/domain.log rainbond/archiver:domain_v2 init --ip {{ pillar['inet-ip'] }}
    - unless:  grep "goodrain" {{ pillar['rbd-path'] }}/.domain.log

update_systeminfo:
  file.managed:
    - source: salt://docker/envs/domain.sh
    - name: /tmp/domain.sh
    - template: jinja
    - mode: 755
  cmd.run:
    - name: bash /tmp/domain.sh

install_manage_compute_ctl:
  cmd.run:
    - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/static gr-compute-all
    - unless: which kubelet
{% endif %}

{% if "manage" in grains['host'] %}
install_manage_ctl:
  cmd.run:
    - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/static gr-ctl-all
    - unless: ls /opt/cni/bin/

{% endif %}

{% if "compute" in grains['host'] %}
install_compute_ctl:
  cmd.run:
    - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/static gr-compute-all
    - unless: which kubelet
{% endif %}


