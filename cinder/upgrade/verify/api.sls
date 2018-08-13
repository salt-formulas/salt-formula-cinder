{%- from "cinder/map.jinja" import controller with context %}
{%- from "keystone/map.jinja" import client as kclient with context %}


cinder_upgrade_verify_api:
  test.show_notification:
    - text: "Running cinder.upgrade.verify.api"

{%- if kclient.enabled and kclient.get('os_client_config', {}).get('enabled', False)  %}
  {%- if controller.enabled %}
    {%- if controller.get('version') not in ('mitaka', 'newton') -%}
      {%- set volume_type_name = 'TestVolumeType' %}

cinderv3_volume_list:
  module.run:
    - name: cinderv3.volume_list
    - kwargs:
        cloud_name: admin_identity

cinderv3_volume_type_present:
  cinderv3.volume_type_present:
  - name: {{ volume_type_name }}
  - cloud_name: admin_identity

cinderv3_volume_type_key_present:
  cinderv3.volume_type_key_present:
  - name: {{ volume_type_name }}
  - key: key1
  - value: val1
  - cloud_name: admin_identity

cinderv3_volume_type_absent:
  cinderv3.volume_type_absent:
  - name: {{ volume_type_name }}
  - cloud_name: admin_identity

    {%- endif %}
  {%- endif %}
{%- endif %}
