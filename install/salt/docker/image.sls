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
{% endif %}

check_domain:
  cmd.run:
<<<<<<< HEAD
    - name:  echo "domain not found"
    - unless: grep "domain" /srv/pillar/system_info.sls
=======
    - name: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock rainbond/static gr-ctl-all
>>>>>>> master

refresh_domain:
  cmd.run:
    - name: salt "*" saltutil.refresh_pillar


