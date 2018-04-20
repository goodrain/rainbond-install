#!/bin/bash

docker cp /tmp/init.sql rbd-db:/root
docker exec rbd-db mysql -e "use console;source /root/init.sql;"

{% if pillar['public-ip'] %}
IP={{ pillar['public-ip'] }}
{% else %}
IP={{ pillar['inet-ip'] }}
{% endif %}

DOMAIN={{ pillar['domain'] }}
cat > /tmp/region_info.sql <<EOF
INSERT INTO \`region_info\` ( \`region_id\`, \`region_name\`, \`region_alias\`, \`url\`, \`token\`, \`status\`, \`desc\`, \`wsurl\`, \`httpdomain\`, \`tcpdomain\`) VALUES('asdasdasdasdasdasdasdasdas', 'cloudbang', '私有数据中心1', 'http://region.goodrain.me:8888', NULL, '1', '当前数据中心是默认安装添加的数据中心', 'ws://$IP:6060', '$DOMAIN', '$IP');
EOF

docker cp /tmp/region_info.sql rbd-db:/root
docker exec rbd-db mysql -e "use console;source /root/region_info.sql;"
