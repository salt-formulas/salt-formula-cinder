{%- from "cinder/map.jinja" import controller with context %}

cinder_syncdb:
  cmd.run:
  - name: 'cinder-manage db sync; sleep 5;'
  {%- if grains.get('noservices') or controller.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
