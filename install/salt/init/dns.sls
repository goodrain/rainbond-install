# add records to /etc/hosts file

# get master(manage01) ip address
{% if "manage" in grains['id'] %}
{% set hostip = grains['mip'] %}
rbd-repo-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - lang.goodrain.me
      - maven.goodrain.me

kube-apiserver-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - kubeapi.goodrain.me

rbd-api-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - region.goodrain.me

rbd-registry-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - goodrain.me

rbd-app-ui-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - console.goodrain.me

{% else %}
# Todo:support VIP
{% set hostip = pillar['vip'] %}

rbd-repo-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - lang.goodrain.me
      - maven.goodrain.me

kube-apiserver-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - kubeapi.goodrain.me

rbd-api-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - region.goodrain.me

rbd-registry-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - goodrain.me

rbd-app-ui-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - console.goodrain.me

update_compute_hosts:
  cmd.run:
    - name: echo "{{ grains['mip'] }} {{ grains['id'] }}" > /etc/hostname
{% endif %}

# Modify /etc/resolv.conf
/etc/resolv.conf:
  file.append:
    - text:
      - "nameserver {{ pillar.dns.master }}"