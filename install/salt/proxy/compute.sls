{% set RUNNERIMG = salt['pillar.get']('proxy:runner:image') -%}
{% set RUNNERVER = salt['pillar.get']('proxy:runner:version') -%}
{% set PRIDOMAIN = salt['pillar.get']('private-image-domain') -%}

compute-runner-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{RUNNERIMG}}:{{ RUNNERVER }}

{% set ADAPTERIMG = salt['pillar.get']('proxy:adapter:image') -%}
{% set ADAPTERVER = salt['pillar.get']('proxy:adapter:version') -%}
compute-adapter-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{ADAPTERIMG}}

{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
compute-pause-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}
    - unless: docker inspect {{PRIDOMAIN}}/{{PAUSEIMG}}:{{ PAUSEVER }}

{% set PLUGINIMG = salt['pillar.get']('plugins:image') -%}
{% set TCMTAG = salt['pillar.get']('plugins:tcm:tag') -%}
{% set MESHTAG = salt['pillar.get']('plugins:mesh:metatag') -%}
compute-tcm-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{TCMTAG}}
    - unless: docker inspect {{PRIDOMAIN}}/{{TCMTAG}}

compute-mesh-pull-image:
  cmd.run:
    - name: docker pull {{PRIDOMAIN}}/{{MESHTAG}}
    - unless: docker inspect {{PRIDOMAIN}}/{{MESHTAG}}