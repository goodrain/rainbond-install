{% if "manage" in grains['id'] %}
{% set hostip = pillar['vip'] %}
{% set localip = grains['mip'][0] %}
kube-apiserver-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - kubeapi.goodrain.me

rbd-registry-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - goodrain.me

rbd-api-domain:
  host.present:
    - ip: {{ hostip }}
    - names:
      - region.goodrain.me

uuid-localip:
  host.present:
    - ip: {{ localip }}
    - names:
      - {{ grains['uuid'] }}


hostname-localname:
  host.present:
    - ip: {{ localip }}
    - names:
      - {{ grains['id'] }}

#rbd-app-ui-domain:
#  host.present:
#    - ip: {{ hostip }}
#    - names:
#      - console.goodrain.me


{% else %}
# Todo:support VIP
{% set hostip = pillar['vip'] %}
{% set localip = grains['mip'][0] %}

#rbd-repo-domain:
#  host.present:
#    - ip: {{ hostip }}
#    - names:
#      - lang.goodrain.me
#      - maven.goodrain.me

#kube-apiserver-domain:
#  host.present:
#    - ip: {{ hostip }}
#    - names:
#      - kubeapi.goodrain.me

#rbd-api-domain:
#  host.present:
#    - ip: {{ hostip }}
#    - names:
#      - region.goodrain.me

#rbd-registry-domain:
#  host.present:
#    - ip: {{ hostip }}
#    - names:
#      - goodrain.me

#rbd-app-ui-domain:
#  host.present:
#    - ip: {{ hostip }}
#    - names:
#      - console.goodrain.me

hostname-domain:
  host.present:
    - ip: {{ localip }}
    - names:
      - {{ grains['id'] }}

uuid-domain:
  host.present:
    - ip: {{ localip }}
    - names:
      - {{ grains['uuid'] }}

{% endif %}

# repo.goodrain.me
local-domain:
  host.present:
    - ip: {{ pillar['master-private-ip'] }}
    - names:
      - repo.goodrain.me

# Modify /etc/resolv.conf
disable_old_dns:
  file.replace:
    - name: /etc/resolv.conf
    - pattern: "^nameserver "
    - repl: "#nameserver "

add_manage_dns:
  file.append:
    - name: /etc/resolv.conf
    - text:
      - "nameserver {{ pillar['master-private-ip'] }}"

add_local_dns:
  file.append:
    - name: /etc/resolv.conf
    - text:
      - "nameserver {{ grains['mip'][0] }}"

add_master_dns:
  file.append:
    - name: /etc/resolv.conf
    - text:
      - "nameserver {{ pillar.dns.get('current','114.114.114.114') }}"

domain-resolv:
  file.replace:
    - name: /etc/resolv.conf
    - pattern: "^domain"
    - repl: "# domain"

search-resolv:
  file.replace:
    - name: /etc/resolv.conf
    - pattern: "^search"
    - repl: "# search"