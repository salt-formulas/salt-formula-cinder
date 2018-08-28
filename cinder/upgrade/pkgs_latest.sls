{%- from "cinder/map.jinja" import controller,volume,backup,client with context %}

cinder_task_pkg_latest:
  test.show_notification:
    - text: "Running cinder.upgrade.pkg_latest"

policy-rc.d_present:
  file.managed:
    - name: /usr/sbin/policy-rc.d
    - mode: 755
    - contents: |
        #!/bin/sh
        exit 101

{%- set pkgs = [] %}
{%- if controller.enabled %}
  {%- do pkgs.extend(controller.pkgs) %}
{%- endif %}
{%- if volume.enabled %}
  {%- do pkgs.extend(volume.pkgs) %}
{%- endif %}
{%- if backup.engine != None %}
  {%- do pkgs.extend(backup.pkgs) %}
{%- endif %}
{%- if client.enabled %}
  {%- do pkgs.extend(client.pkgs) %}
{%- endif %}

cinder_pkg_latest:
  pkg.latest:
  - names: {{ pkgs|unique }}
  - require:
    - file: policy-rc.d_present
  - require_in:
    - file: policy-rc.d_absent

policy-rc.d_absent:
  file.absent:
    - name: /usr/sbin/policy-rc.d
