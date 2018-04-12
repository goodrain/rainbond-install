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