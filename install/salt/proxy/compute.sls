{% set RUNNERIMG = salt['pillar.get']('proxy:runner:image') -%}
{% set RUNNERVER = salt['pillar.get']('proxy:runner:version') -%}
compute-runner-pull-image:
  cmd.run:
<<<<<<< HEAD
    - name: docker pull goodrain.me/runner
=======
    - name: docker pull goodrain.me/runner:{{ RUNNERVER }}
    - unless: docker inspect goodrain.me/runner:{{ RUNNERVER }}
>>>>>>> reconsitution

{% set ADAPTERIMG = salt['pillar.get']('proxy:adapter:image') -%}
{% set ADAPTERVER = salt['pillar.get']('proxy:adapter:version') -%}
compute-adapter-pull-image:
  cmd.run:
    - name: docker pull goodrain.me/adapter

{% set PAUSEIMG = salt['pillar.get']('proxy:pause:image') -%}
{% set PAUSEVER = salt['pillar.get']('proxy:pause:version') -%}
compute-pause-pull-image:
  cmd.run:
<<<<<<< HEAD
    - name: docker pull goodrain.me/pause-amd64:3.0
=======
    - name: docker pull goodrain.me/pause-amd64:{{ PAUSEVER }}
    - unless: docker inspect goodrain.me/pause-amd64:{{ PAUSEVER }}
>>>>>>> reconsitution

{% set TCMIMG = salt['pillar.get']('proxy:plugins:image') -%}
{% set TCMVER = salt['pillar.get']('proxy:plugins:version') -%}
compute-tcm-pull-image:
  cmd.run:
<<<<<<< HEAD
    - name: docker pull goodrain.me/tcm

compute-mesh-pull-image:    
  cmd.run:
    - name: docker pull goodrain.me/mesh_plugin
=======
    - name: docker pull goodrain.me/tcm:{{ TCMVER }}
    - unless: docker inspect goodrain.me/tcm:{{ TCMVER }}
>>>>>>> reconsitution
