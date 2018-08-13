{%- from "cinder/map.jinja" import controller,volume,backup,upgrade with context %}

cinder_task_service_stopped:
  test.show_notification:
    - text: "Running cinder.upgrade.service_stopped"

{%- set cservices = [] %}
{%- if controller.enabled %}
  {%- do cservices.extend(controller.services) %}
  {#- After newton release cinder running under apache #}
  {%- if upgrade.old_release in ['mitaka', 'newton'] %}
    {%- do cservices.append('cinder-api') %}
  {%- else %}
    {%- do cservices.append('apache2') %}
  {%- endif %}
{%- endif %}
{%- if volume.enabled %}
   {%- do cservices.extend(volume.services) %}
{%- endif %}
{%- if backup.engine != None %}
  {%- do cservices.extend(backup.services) %}
{%- endif %}

{%- for cservice in cservices|unique %}
cinder_service_stopped_{{ cservice }}:
  service.dead:
  - name: {{ cservice }}
  - enable: False
{%- endfor %}
