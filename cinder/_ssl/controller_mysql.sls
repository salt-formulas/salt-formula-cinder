{% from "cinder/map.jinja" import controller with context %}

cinder_controller_ssl_mysql:
  test.show_notification:
    - text: "Running cinder._ssl.controller_mysql"

{%- if controller.database.get('x509',{}).get('enabled',False) %}

  {%- set ca_file=controller.database.x509.ca_file %}
  {%- set key_file=controller.database.x509.key_file %}
  {%- set cert_file=controller.database.x509.cert_file %}

mysql_cinder_controller_ssl_x509_ca:
  {%- if controller.database.x509.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: cinder:controller:database:x509:cacert
    - mode: 444
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

mysql_cinder_controller_client_ssl_cert:
  {%- if controller.database.x509.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: cinder:controller:database:x509:cert
    - mode: 440
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cert_file }}
  {%- endif %}

mysql_cinder_controller_client_ssl_private_key:
  {%- if controller.database.x509.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: cinder:controller:database:x509:key
    - mode: 400
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ key_file }}
  {%- endif %}

mysql_cinder_controller_ssl_x509_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: cinder
    - group: cinder

{% elif controller.database.get('ssl',{}).get('enabled',False) %}
mysql_ca_cinder_controller:
  {%- if controller.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ controller.database.ssl.cacert_file }}
    - contents_pillar: cinder:controller:database:ssl:cacert
    - mode: 0444
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ controller.database.ssl.get('cacert_file', controller.cacert_file) }}
  {%- endif %}

{%- endif %}