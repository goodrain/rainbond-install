firewalld:
  service.dead:
    - name: firewalld
    - enable: False 

dnsmasq:
  service.dead:
    - name: dnsmasq
    - enable: False
  cmd.run:
    - name: killall -9 dnsmasq
    - onlyif: pgrep dnsmasq

#kill-dhclient:
#  cmd.run:
#    - name: pkill -9 dhclient
#    - onlyif: pgrep dhclient

remove_pkgs:
  pkg.removed:
    - pkgs:
      - nscd
      - dnsmasq
#      - dhclient
    - require:
      - service: dnsmasq
      - cmd: dnsmasq
#      - cmd: kill-dhclient

{% if grains['os_family']|lower == 'debian' %}
#NetworkManager:
#  service.dead:
#    - name: NetworkManager
#    - enable: False
NetworkManager-conf:
  file.managed:
    - source: salt://install/files/network/system/calico.conf
    - name: /etc/NetworkManager/conf.d/calico.conf
    - template: jinja
    - mode: 755
    - makedirs: True
{% endif %}

iptables:
  cmd.run:
    - name: iptables -F;iptables -X;iptables -Z
    - unless: iptables -L -nv  | grep DOCKER
