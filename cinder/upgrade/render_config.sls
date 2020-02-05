{%- from "cinder/map.jinja" import controller,volume with context %}

{%- if volume.enabled %}
  {%- set _data = volume %}
  {%- set type = 'volume' %}
{%- elif controller.enabled %}
  {%- set _data = controller %}
  {%- set type = 'controller' %}
{%- endif %}

/etc/cinder/cinder.conf:
  file.managed:
  - source: salt://cinder/files/{{ _data.version }}/cinder.conf.{{ type }}.{{ grains.os_family }}
  - template: jinja
