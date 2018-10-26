{%- from "cinder/map.jinja" import client with context %}
{%- if client.get('enabled', False) %}

cinder_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

{% if client.identity is mapping %}
{%- set identity = client.identity %}
{%- else %}
{%- set identity = salt['pillar.get']('keystone:client:server:'+client.identity) %}
{%- endif %}

{#- Keystone V3 is supported only from Ocata release (https://docs.openstack.org/releasenotes/python-cinderclient/ocata.html) #}
{#- Therefore if api_version is not defined and OpenStack version is mitaka or newton use v2.0. #}
{%- if 'api_version' in identity %}
{%- set keystone_api_version = identity.get('api_version') %}
{%- else %} 
{%- if 'version' in client and client.version in ['mitaka', 'newton'] %}
{%- set keystone_api_version = 'v2.0' %}
{%- else %}
{%- set keystone_api_version = 'v3' %}
{%- endif %}
{%- endif %}

{%- set credentials = {'host': identity.host,
                       'user': identity.user,
                       'password': identity.password,
                       'project_id': identity.project,
                       'port': identity.get('port', 35357),
                       'protocol': identity.get('protocol', 'http'),
                       'region_name': identity.get('region', 'RegionOne'),
                       'endpoint_type': identity.get('endpoint_type', 'internalURL'),
                       'certificate': identity.get('certificate', client.cacert_file),
                       'api_version': keystone_api_version} %}

{%- for backend_name, backend in client.get('backend', {}).items() %}

cinder_type_create_{{ backend_name }}:
  cinderv3.volume_type_present:
  - name: {{ backend.type_name }}
  - cloud_name: admin_identity
  - require:
    - pkg: cinder_client_packages

cinder_type_update_{{ backend_name }}:
  cinderv3.volume_type_key_present:
  - name: {{ backend.type_name }}
  - key: volume_backend_name
  - value: {{ backend_name }}
  - cloud_name: admin_identity
  - require:
    - cinderv3: cinder_type_create_{{ backend_name }}

{%- for key_name, key_value in backend.get('key', {}).items() %}

cinder_type_update_{{ backend_name }}_{{ key_name }}:
  cinderv3.volume_type_key_present:
  - name: {{ backend.type_name }}
  - key: {{ key_name }}
  - value: {{ key_value }}
  - cloud_name: admin_identity
  - require:
    - cinderv3: cinder_type_create_{{ backend_name }}

{%- endfor %}

{%- endfor %}

{%- endif %}
