# calico

```
include:
  - network.calico.service
  {% if grains['id'] == 'manage01'  %}
  - network.calico.setup
  {% endif %
```

# Todo  

- 使用setup.sls