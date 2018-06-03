update_compute_hostname:
  cmd.run:
    - name: hostname {{ grains['id'] }}; echo "{{ grains['id'] }}" > /etc/hostname

{% if grains['os_family']|lower == 'redhat' %}
{% if pillar['install-type']=="offline" %}
# config dns for repo-server  
dns-manage:
  cmd.run: 
    - name: echo 'nameserver {{ pillar['inet-ip'] }}' > /etc/resolv.conf
#backup org repos
backup-repo-dir:
  file.directory:
    - name: /etc/yum.repos.d/backup
    - mkdir: True
    - unless: /etc/yum.repos.d/backup
#backup org repos
backup-repo:
  cmd.run:
    - name: mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup
#config local repo
local-repo:
  pkgrepo.managed:
    - humanname: local_repo
    - baseurl: http://repo.goodrain.me/
    - enabled: 1
    - gpgcheck: 0
# online
{% else %}
epel-repo:
  pkgrepo.managed:
    - humanname: Extra Packages for Enterprise Linux 7 - $basearch
    - baseurl: http://mirrors.aliyun.com/epel/7/$basearch
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    - gpgcheck: 1
  {% endif %}
# debain or ubuntu
{% else %}
update_local_pkg_cache:
  cmd.run:
    - name: apt update -y
{% endif %} 

#install base pkgs
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
    
# sync time online
{% if pillar['install-type']!="offline" %}
update_time:
  cmd.run:
    - name: ntpdate ntp1.aliyun.com ntp2.aliyun.com ntp3.aliyun.com
{% endif %}