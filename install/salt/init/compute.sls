update_compute_hostname:
  cmd.run:
    - name: hostname {{ grains['id'] }}; echo "{{ grains['id'] }}" > /etc/hostname

{% if grains['os_family']|lower == 'redhat' %}

# epel repo
epel-repo:
  pkgrepo.managed:
    - humanname: Extra Packages for Enterprise Linux 7 - $basearch
    - baseurl: http://mirrors.aliyun.com/epel/7/$basearch
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    - gpgcheck: 1

update_local_pkg_cache:
  cmd.run:
    - name: yum makecache fast

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
    - name: ntpdate ntp1.aliyun.com ntp2.aliyun.com ntp3.aliyun.com