{% set REPOIMG = salt['pillar.get']('rainbond-modules:rbd-repo:image') -%}
{% set REPOVER = salt['pillar.get']('rainbond-modules:rbd-repo:version') -%}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

docker-pull-repo-image:
  cmd.run:
{% if pillar['install-type']!="offline" %}
    - name: docker pull {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}
{% else %}
    - name: docker load -i {{ pillar['install-script-path'] }}/install/imgs/{{PUBDOMAIN}}_{{ REPOIMG }}_{{ REPOVER }}.gz
{% endif %}
    - unless: docker inspect {{PUBDOMAIN}}/{{ REPOIMG }}:{{ REPOVER }}

repo-upstart:
  cmd.run:
    - name: dc-compose up -d rbd-repo
    - unless: check_compose rbd-repo
    - require:
      - cmd: docker-pull-repo-image