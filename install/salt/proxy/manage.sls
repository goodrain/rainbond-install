{% if grains['id'] == "manage01" %}
{% set PUBDOMAIN = salt['pillar.get']('public-image-domain') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}
pull-plugin-tcm:
  cmd.run:
    - name: docker pull {{ PUBDOMAIN }}/plugins:tcm

retag-plugin-tcm:
  cmd.run:
    - name: docker tag {{ PUBDOMAIN }}/plugins:tcm {{ PRIDOMAIN }}/tcm
    - require:
        - cmd: pull-plugin-tcm


push-plugin-tcm:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/tcm
    - require:
        - cmd: retag-plugin-tcm

pull-plugin-mesh:
  cmd.run:
    - name: docker pull {{PUBDOMAIN}}/plugins:mesh_plugin
    - unless: docker inspect {{PUBDOMAIN}}/plugins:mesh_plugin

retag-plugin-mesh:
  cmd.run:
    - name: docker tag {{PUBDOMAIN}}/plugins:mesh_plugin {{PRIDOMAIN}}/mesh_plugin
    - require:
        - cmd: pull-plugin-mesh

push-plugin-mesh:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/mesh_plugin
    - require:
        - cmd: retag-plugin-mesh

{% set RUNNERIMG = salt['pillar.get']('proxy:runner:image') -%}
{% set RUNNERVER = salt['pillar.get']('proxy:runner:version') -%}
runner-pull-image:
  cmd.run:
    - name: docker pull {{ RUNNERIMG }}:{{ RUNNERVER }}
    - unless: docker inspect {{ RUNNERIMG }}:{{ RUNNERVER }}

runner-tag:
  cmd.run:
    - name: docker tag {{ RUNNERIMG }}:{{ RUNNERVER }} {{PRIDOMAIN}}/runner:{{ RUNNERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/runner:{{ RUNNERVER }}
    - require:
        - cmd: runner-pull-image

runner-push-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/runner:{{ RUNNERVER }}
    - require:
        - cmd: runner-tag

{% set ADAPTERIMG = salt['pillar.get']('proxy:adapter:image') -%}
{% set ADAPTERVER = salt['pillar.get']('proxy:adapter:version') -%}
adapter-pull-image:
  cmd.run:
    - name: docker pull {{ ADAPTERIMG }}:{{ ADAPTERVER }}
    - unless: docker inspect {{ ADAPTERIMG }}:{{ ADAPTERVER }}

adapter-tag:
  cmd.run:
    - name: docker tag {{ ADAPTERIMG }}:{{ ADAPTERVER }} {{PRIDOMAIN}}/adapter:{{ ADAPTERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/adapter:{{ ADAPTERVER }}
    - require:
        - cmd: adapter-pull-image

adapter-push-image:    
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/adapter:{{ ADAPTERVER }}
    - require:
        - cmd: adapter-tag

{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
pause-pull-image:
  cmd.run:
    - name: docker pull {{ PAUSEIMG }}:{{ PAUSEVER }}
    - unless: docker inspect {{ PAUSEIMG }}:{{ PAUSEVER }}

pause-tag:
  cmd.run:
    - name: docker tag {{ PAUSEIMG }}:{{ PAUSEVER }} {{PRIDOMAIN}}/pause-amd64:{{ PAUSEVER }}
    - unless: docker inspect {{PRIDOMAIN}}/pause-amd64:{{ PAUSEVER }}
    - require:
        - cmd: pause-pull-image

pause-push-image:
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/pause-amd64:{{ PAUSEVER }}
    - require:
        - cmd: pause-tag

{% set BUILDERIMG = salt['pillar.get']('proxy:builder:image') -%}
{% set BUILDERVER = salt['pillar.get']('proxy:builder:version') -%}
builder-pull-image:
  cmd.run:
    - name: docker pull {{ BUILDERIMG }}:{{ BUILDERVER }}
    - unless: docker inspect {{ BUILDERIMG }}:{{ BUILDERVER }}

builder-tag:  
  cmd.run:
    - name: docker tag {{ BUILDERIMG }}:{{ BUILDERVER }} {{PRIDOMAIN}}/builder:{{ BUILDERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/builder:{{ BUILDERVER }}
    - require:
        - cmd: builder-pull-image

builder-push-image:    
  cmd.run:
    - name: docker push {{PRIDOMAIN}}/builder:{{ BUILDERVER }}
    - require:
        - cmd: builder-tag

{% else %}
builder-mpull-image:    
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/builder

pause-mpull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/pause-amd64:3.0
{% endif %}