update_compute_hostname:
  cmd.run:
    - name: hostname {{ grains['id'] }}; echo "{{ grains['id'] }}" > /etc/hostname