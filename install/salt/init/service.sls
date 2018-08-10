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

remove_pkgs:
  pkg.removed:
    - pkgs:
      - nscd
      - dnsmasq
    - require:
      - service: dnsmasq
      - cmd: dnsmasq
    
{% if grains['os_family']|lower == 'debian' %}
NetworkManager:
  service.dead:
    - name: NetworkManager
    - enable: False
{% endif %}

iptables:
  cmd.run:
    - name: iptables -F;iptables -X;iptables -Z
    - unless: iptables -L -nv  | grep DOCKER
