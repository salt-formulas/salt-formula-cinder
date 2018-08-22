{% from "cinder/map.jinja" import volume with context %}

cinder_volume_ssl_mysql:
  test.show_notification:
    - text: "Running cinder._ssl.volume-mysql"

{%- if volume.database.get('x509',{}).get('enabled',False) %}

  {%- set ca_file=volume.database.x509.ca_file %}
  {%- set key_file=volume.database.x509.key_file %}
  {%- set cert_file=volume.database.x509.cert_file %}

mysql_cinder_volume_ssl_x509_ca:
  {%- if volume.database.x509.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: cinder:volume:database:x509:cacert
    - mode: 444
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

mysql_cinder_volume_client_ssl_cert:
  {%- if volume.database.x509.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: cinder:volume:database:x509:cert
    - mode: 440
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cert_file }}
  {%- endif %}

mysql_cinder_volume_client_ssl_private_key:
  {%- if volume.database.x509.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: cinder:volume:database:x509:key
    - mode: 400
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ key_file }}
  {%- endif %}

mysql_cinder_volume_ssl_x509_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: cinder
    - group: cinder

{% elif volume.database.get('ssl',{}).get('enabled',False) %}
mysql_ca_cinder_volume:
  {%- if volume.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ volume.database.ssl.cacert_file }}
    - contents_pillar: cinder:volume:database:ssl:cacert
    - mode: 0444
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ volume.database.ssl.get('cacert_file', volume.cacert_file) }}
  {%- endif %}

{%- endif %}