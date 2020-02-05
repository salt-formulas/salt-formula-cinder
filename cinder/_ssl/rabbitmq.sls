{% from "cinder/map.jinja" import controller, volume with context %}

{%- if controller.enabled == True %}
  {%- set cinder_msg = controller.message_queue %}
  {%- set cinder_cacert = controller.cacert_file %}
  {%- set role = 'controller' %}
{%- else %}
  {%- set cinder_msg = volume.message_queue %}
  {%- set cinder_cacert = volume.cacert_file %}
  {%- set role = 'volume' %}
{%- endif %}

cinder_{{ role }}_ssl_rabbitmq:
  test.show_notification:
    - text: "Running cinder._ssl.rabbitmq"

{%- if cinder_msg.get('x509',{}).get('enabled',False) %}

  {%- set ca_file=cinder_msg.x509.ca_file %}
  {%- set key_file=cinder_msg.x509.key_file %}
  {%- set cert_file=cinder_msg.x509.cert_file %}

rabbitmq_cinder_{{ role }}_ssl_x509_ca:
  {%- if cinder_msg.x509.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: cinder:{{ role }}:message_queue:x509:cacert
    - mode: 444
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

rabbitmq_cinder_{{ role }}_client_ssl_cert:
  {%- if cinder_msg.x509.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: cinder:{{ role }}:message_queue:x509:cert
    - mode: 440
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cert_file }}
  {%- endif %}

rabbitmq_cinder_{{ role }}_client_ssl_private_key:
  {%- if cinder_msg.x509.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: cinder:{{ role }}:message_queue:x509:key
    - mode: 400
    - user: cinder
    - group: cinder
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ key_file }}
  {%- endif %}

rabbitmq_cinder_{{ role }}_ssl_x509_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: cinder
    - group: cinder

{% elif cinder_msg.get('ssl',{}).get('enabled',False) %}
rabbitmq_ca_cinder_{{ role }}_client:
  {%- if cinder_msg.ssl.cacert is defined %}
  file.managed:
    - name: {{ cinder_msg.ssl.cacert_file }}
    - contents_pillar: cinder:{{ role }}:message_queue:ssl:cacert
    - mode: 0444
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cinder_msg.ssl.get('cacert_file', cinder_cacert) }}
  {%- endif %}

{%- endif %}
