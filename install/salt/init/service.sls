firewalld:
  service.dead:
    - name: firewalld
    - enable: False 

clear_firewall_rules:
  cmd.run:
    - name: iptables -F && iptables -X && iptables -Z

dnsmasq:
  service.dead:
    - name: dnsmasq
    - enable: False 

nscd:
  pkg.removed:
    - pkgs:
      - nscd

NetworkManager:
  service.dead:
    - name: NetworkManager
    - enable: False