[ -f "/tmp/LOCAL_IP" ] && (
  ip=$(cat /tmp/LOCAL_IP 2> /dev/null)
) || (
  ip=$(ip ad|grep inet|egrep ' 10.|172.|192.168'|awk '{print $2}'|cut -d '/' -f 1|grep -v '172.30.42.1'|head -1)
)
[ -f "/tmp/.role" ] && role="worker" || cat /etc/hostname | grep compute && role="worker" || role="master"

if [ -z "$uuid" ];then
cat > /etc/salt/minion.d/minion.ex.conf <<EOF
grains:
  mip:
    - $ip
  node_role:
    - $role
EOF
else
cat > /etc/salt/minion.d/minion.ex.conf <<EOF
grains:
  uuid: $uuid             
  mip:
    - $ip
  node_role:
    - $role
EOF
fi
