## 不支持节点支持复用

```
# old init.sls

include:
{% if "manage" in grains['host'] and grains['host'] != "manage01" %}
  - kubernetes.master
{% elif grains['host'] == "manage01" %}
  - kubernetes.master
  - kubernetes.node
{% else %}
  - kubernetes.node
{% endif %}
```