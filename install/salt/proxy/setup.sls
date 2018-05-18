{% if grains['id'] == "manage01" %}
pull-plugin-tcm:
  cmd.run:
    - name: docker pull rainbond/plugins:tcm

retag-plugin-tcm:
  cmd.run:
    - name: docker tag rainbond/plugins:tcm goodrain.me/tcm

push-plugin-tcm:
  cmd.run:
    - name: docker push goodrain.me/tcm

pull-plugin-mesh:
  cmd.run:
    - name: docker pull rainbond/plugins:mesh_plugin

retag-plugin-mesh:
  cmd.run:
    - name: docker tag rainbond/plugins:mesh_plugin goodrain.me/mesh_plugin

push-plugin-mesh:
  cmd.run:
    - name: docker push goodrain.me/mesh_plugin
{% endif %}