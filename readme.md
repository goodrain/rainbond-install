##  云帮私有化安装程序

云帮私有化安装程序基于saltstack 制作而成。

```bash
# 检查 内网IP地址
salt-call --config-dir install  network.ip_addrs type=private --out=json | jq .local[]


# 检查公网
salt-call --config-dir install network.connect www.rainbond.com 80 timeout=3 --output=json | jq .local.result


# 检查默认路由
salt-call --config-dir install network.default_route --output=json | jq .local[].gateway
