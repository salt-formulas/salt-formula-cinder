{%- from "cinder/map.jinja" import volume with context %}
{%- if volume.enabled %}

{%- if pillar.cinder.controller is not defined %}
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

{%- if not pillar.cinder.get('controller', {}).get('enabled', False) %}

/etc/cinder/cinder.conf:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder.conf.volume.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_volume_packages

/etc/cinder/api-paste.ini:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/api-paste.ini.volume.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_volume_packages

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
  - watch:
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{%- endif %}

{%- endif %}

cinder_volume_services:
  service.running:
  - names: {{ volume.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{# new way #}

{%- if volume.backend is defined %}

{%- for backend_name, backend in volume.get('backend', {}).iteritems() %}

{%- if backend.get('engine') == 'nfs' or (backend.get('engine') == 'netapp' and backend.get('storage_protocol') == 'nfs') %}
/etc/cinder/nfs_shares_{{ backend_name }}_for_cinder_volume:
  file.managed:
  - name: /etc/cinder/nfs_shares_{{ backend_name }}
  - source: salt://cinder/files/{{ volume.version }}/nfs_shares
  - defaults:
      backend: {{ backend|yaml }}
  - template: jinja
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
  - defaults:
      backend_name: "{{ backend_name }}"
  - require:
    - pkg: cinder-driver-fujitsu

{%- endif %}

{%- endfor %}

{%- endif %}

{# old way #}

{%- if volume.storage is defined %}

{%- if volume.storage.engine in ['iscsi', 'hp_lefthand'] %}

cinder_iscsi_packages:
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
    - pkg: cinder_iscsi_packages

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

{%- if volume.storage.engine == 'hitachi_vsp' %}

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

{%- if volume.storage.engine == 'hp3par' %}

hp3parclient:
  pkg.latest:
    - name: python-hp3parclient

{%- endif %}

{%- if volume.storage.engine == 'fujitsu' %}

cinder_driver_fujitsu:
  pkg.latest:
    - name: cinder-driver-fujitsu

{%- for type in volume.get('types', []) %}

/etc/cinder/cinder_fujitsu_eternus_dx_{{ type.name }}.xml:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder_fujitsu_eternus_dx.xml
  - template: jinja
  - defaults:
      volume_type_name: "{{ type.pool }}"
  - require:
    - pkg: cinder-driver-fujitsu

{%- endfor %}

{%- endif %}

{%- endif %}


{%- endif %}
