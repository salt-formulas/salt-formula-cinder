{% from "cinder/map.jinja" import controller with context %}

cinder_controller_online_data_migrations:
  cmd.run:
  - name: cinder-manage db online_data_migrations
  {%- if grains.get('noservices') or controller.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
