update_compute_hostname:
  cmd.run:
    - name: hostname {{ grains['id'] }}; echo "{{ grains['id'] }}" > /etc/hostname
{% if grains['os_family']|lower == 'redhat' %}
update_local_pkg_cache:
  cmd.run:
    - name: yum makecache
{% else %}
update_local_pkg_cache:
  cmd.run:
    - name: apt update -y
{% endif %} 
install_req_pkgs:
  pkg.installed:
    - pkgs:
      - ntpdate
      - lsof
      - htop 
      - nload 
      - rsync 
      - net-tools
    - refresh: true

update_time:
  cmd.run:
    - name: ntpdate 0.cn.pool.ntp.org