{%- from "cinder/map.jinja" import volume with context %}

{%- if volume.enabled %}

include:
  - cinder._ssl.volume-mysql

{%- if not pillar.cinder.get('controller', {}).get('enabled', False) %}
{%- set user = volume %}
{%- include "cinder/user.sls" %}
{%- endif %}

cinder_volume_packages:
  pkg.installed:
  - names: {{ volume.pkgs }}

/var/lock/cinder:
  file.directory:
  - mode: 755
  - user: cinder
  - group: cinder
  - require:
    - pkg: cinder_volume_packages
  - require_in:
    - service: cinder_volume_services

{%- if volume.message_queue.get('ssl',{}).get('enabled', False) %}
rabbitmq_ca_cinder_volume:
{%- if volume.message_queue.ssl.cacert is defined %}
  file.managed:
    - name: {{ volume.message_queue.ssl.cacert_file }}
    - contents_pillar: cinder:volume:message_queue:ssl:cacert
    - mode: 0444
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ volume.message_queue.ssl.get('cacert_file', volume.cacert_file) }}
{%- endif %}
{%- endif %}

{%- set cinder_log_services = volume.services %}

{%- if not pillar.cinder.get('controller', {}).get('enabled', False) %}

/etc/cinder/cinder.conf:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder.conf.volume.{{ grains.os_family }}
  - template: jinja
  - mode: 0640
  - user: root
  - group: cinder
  - require:
    - sls: cinder._ssl.volume-mysql
    - pkg: cinder_volume_packages

/etc/cinder/api-paste.ini:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/api-paste.ini.volume.{{ grains.os_family }}
  - template: jinja
  - mode: 0640
  - group: cinder
  - require:
    - pkg: cinder_volume_packages

{%- if volume.backup.engine != None %}
  {%- do cinder_log_services.extend(volume.backup.services) %}
{%- endif %}

{%- if volume.backup.engine != None %}

cinder_backup_packages:
  pkg.installed:
  - names: {{ volume.backup.pkgs }}

cinder_backup_services:
  service.running:
  - names: {{ volume.backup.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: cinder._ssl.volume-mysql
  - watch:
    {%- if volume.message_queue.get('ssl',{}).get('enabled', False) %}
    - file: rabbitmq_ca_cinder_volume
    {%- endif %}
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{%- endif %}

{%- endif %}

{% for service_name in cinder_log_services %}
{{ service_name }}_default:
  file.managed:
    - name: /etc/default/{{ service_name }}
    - source: salt://cinder/files/default
    - template: jinja
    - defaults:
        service_name: {{ service_name }}
        values: {{ volume }}
    - require:
      - pkg: cinder_volume_packages
{%- if volume.backup.engine != None %}
      - pkg: cinder_backup_packages
{%- endif %}
    - watch_in:
      - service: cinder_volume_services
{%- if volume.backup.engine != None %}
      - pkg: cinder_backup_services
{%- endif %}
{% endfor %}

{% if volume.logging.log_appender %}

{%- if volume.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
cinder_volume_fluentd_logger_package:
  pkg.installed:
    - name: python-fluent-logger
{%- endif %}

{% for service_name in cinder_log_services %}
{{ service_name }}_logging_conf:
  file.managed:
    - name: /etc/cinder/logging/logging-{{ service_name }}.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - makedirs: True
    - mode: 0640
    - user: root
    - group: cinder
    - defaults:
        service_name: {{ service_name }}
        _data: {{ volume.logging }}
    - require:
      - pkg: cinder_volume_packages
{%- if volume.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: cinder_volume_fluentd_logger_package
{%- endif %}
{%- if not pillar.cinder.get('controller', {}).get('enabled', False) and volume.backup.engine != None %}
      - pkg: cinder_backup_packages
{%- endif %}
    - watch_in:
      - service: cinder_volume_services
{%- if not pillar.cinder.get('controller', {}).get('enabled', False) and volume.backup.engine != None %}
      - pkg: cinder_backup_services
{%- endif %}
{% endfor %}

{% endif %}

cinder_volume_services:
  service.running:
  - names: {{ volume.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: cinder._ssl.volume-mysql
  - watch:
    {%- if volume.message_queue.get('ssl',{}).get('enabled', False) %}
    - file: rabbitmq_ca_cinder_volume
    {%- endif %}
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{%- if volume.backend is defined %}

{%- for backend_name, backend in volume.get('backend', {}).items() %}

{%- if backend.get('engine') == 'nfs' or (backend.get('engine') == 'netapp' and backend.get('storage_protocol') == 'nfs') %}
/etc/cinder/nfs_shares_{{ backend_name }}_for_cinder_volume:
  file.managed:
  - name: /etc/cinder/nfs_shares_{{ backend_name }}
  - source: salt://cinder/files/{{ volume.version }}/nfs_shares
  - defaults:
      backend: {{ backend|yaml }}
  - template: jinja
  - mode: 0640
  - group: cinder
  - require:
    - pkg: cinder_volume_packages

cinder_netapp_packages_for_cinder_volume:
  pkg.installed:
    - pkgs:
      - nfs-common

{%- endif %}

{%- if backend.engine in ['iscsi' , 'hp_lefthand'] %}

cinder_iscsi_packages_{{ loop.index }}:
  pkg.installed:
  - names:
    - iscsitarget
    - open-iscsi
    - iscsitarget-dkms
  - require:
    - pkg: cinder_volume_packages

/etc/default/iscsitarget:
  file.managed:
  - source: salt://cinder/files/iscsitarget
  - template: jinja
  - require:
    - pkg: cinder_iscsi_packages_{{ loop.index }}

cinder_scsi_service:
  service.running:
  - names:
    - iscsitarget
    - open-iscsi
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/default/iscsitarget

{%- endif %}

{%- if backend.engine == 'hitachi_vsp' %}

{%- if grains.os_family == 'Debian' and volume.version == 'juno' %}

hitachi_pkgs:
  pkg.latest:
    - names:
      - horcm
      - hbsd

cinder_hitachi_vps_dir:
  file.directory:
  - name: /var/lock/hbsd
  - user: cinder
  - group: cinder

{%- endif %}

{%- endif %}

{%- if backend.engine == 'hp3par' %}

hp3parclient:
  pkg.latest:
    - name: python-hp3parclient

{%- endif %}

{%- if backend.engine == 'fujitsu' %}

cinder_driver_fujitsu_{{ loop.index }}:
  pkg.latest:
    - name: cinder-driver-fujitsu
    - refresh: true

/etc/cinder/cinder_fujitsu_eternus_dx_{{ backend_name }}.xml:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder_fujitsu_eternus_dx.xml
  - template: jinja
  - mode: 0640
  - group: cinder
  - defaults:
      backend_name: "{{ backend_name }}"
  - require:
    - pkg: cinder-driver-fujitsu

{%- endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
