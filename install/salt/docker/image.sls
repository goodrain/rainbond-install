dps:
    cmd.run:
      - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-docker-utils
      - unless: which dps
    
#dc-compose:
#    cmd.run:
#      - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-docker-compose
#      - unless: which dc-compose

install-docker-compose:
  cmd.run:
    #- name: curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    - name: curl -L https://get.daocloud.io/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    - unless: which docker-compose
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
    - name: touch {{ pillar['rbd-path'] }}/.domain.log

make_domain:
  cmd.run:
    - name: docker run  --rm -v {{ pillar['rbd-path'] }}/.domain.log:/tmp/domain.log rainbond/archiver:domain_v2 init --ip {{ pillar['inet-ip'] }}

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
    - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-compute-all
    - unless: which kubelet
{% endif %}

{% if "manage" in grains['host'] %}
install_manage_ctl:
  cmd.run:
    - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-ctl-all
    - unless: which grctl

{% endif %}

{% if "compute" in grains['host'] %}
install_compute_ctl:
  cmd.run:
    - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/archiver gr-compute-all
    - unless: which kubelet
{% endif %}


