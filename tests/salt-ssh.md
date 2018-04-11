## Master

> yum install -y salt-ssh

/etc/salt/roster

```
compute01:
  host: 192.168.199.13
  user: root
  passwd: 12345678
  sudo: True
```

## 测试

```
salt-ssh -i '*' test.ping
salt-ssh -i "*" state.sls minions.install test=True
```