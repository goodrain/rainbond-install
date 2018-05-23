#!/bin/bash

docker cp /tmp/init.sql rbd-db:/root
docker exec rbd-db mysql -e "use console;truncate table console_sys_config"
docker exec rbd-db mysql -e "use console;source /root/init.sql;"

{% if pillar['master-public-ip'] %}
IP={{ pillar['master-public-ip'] }}
{% else %}
IP={{ pillar['master-private-ip'] }}
{% endif %}

DOMAIN={{ pillar['domain'] }}
cat > /tmp/region_info.sql <<EOF
INSERT INTO \`region_info\` ( \`region_id\`, \`region_name\`, \`region_alias\`, \`url\`, \`token\`, \`status\`, \`desc\`, \`wsurl\`, \`httpdomain\`, \`tcpdomain\`) VALUES('asdasdasdasdasdasdasdasdas', 'rainbond', '私有数据中心1', 'http://region.goodrain.me:8888', NULL, '1', '当前数据中心是默认安装添加的数据中心', 'ws://$IP:6060', '$DOMAIN', '$IP');
EOF
check=$(docker exec rbd-db mysql -e "use console;select *  from region_info where region_id='asdasdasdasdasdasdasdasdas';")
if [ -z $check ];then
    docker cp /tmp/region_info.sql rbd-db:/root
    docker exec rbd-db mysql -e "use console;source /root/region_info.sql;"
fi

rm -rf /tmp/*.sql