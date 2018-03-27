# calico

```
include:
  - network.calico.service
  {% if grains['host'] == 'manage01'  %}
  - network.calico.setup
  {% endif %
```

# Todo  

- 使用setup.sls