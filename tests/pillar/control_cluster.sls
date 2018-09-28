cinder:
  controller:
    enabled: true
    version: liberty
    osapi:
      host: 127.0.0.1
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: cinder
      user: cinder
      password: password
    identity:
      engine: keystone
      region: RegionOne
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: cinder
      password: password
      endpoint_type: internalURL
    glance:
      host: 127.0.0.1
      port: 9292
    logging:
      log_appender: false
      log_handlers:
        watchedfile:
          enabled: true
        fluentd:
          enabled: false
        ossyslog:
          enabled: false
    message_queue:
      engine: rabbitmq
      members:
      - host: 127.0.0.1
      - host: 127.0.1.1
      - host: 127.0.2.1
      user: openstack
      password: password
      virtual_host: '/openstack'
    cache:
      engine: memcached
      members:
      - host: 127.0.0.1
        port: 11211
      - host: 127.0.0.1
        port: 11211
      - host: 127.0.0.1
        port: 11211
      security:
        enabled: true
        strategy: ENCRYPT
        secret_key: secret
    storage:
      engine: storwize
      host: 192.168.0.1
      port: 22
      user: username
      password: pass

    audit:
      filter_factory: 'keystonemiddleware.audit:filter_factory'
      map_file: '/etc/pycadf/cinder_api_audit_map.conf'
    policy:
      'volume:delete': 'rule:admin_or_owner'
      'volume:extend':
apache:
  server:
    enabled: true
    default_mpm: event
    mpm:
      prefork:
        enabled: true
        servers:
          start: 5
          spare:
            min: 2
            max: 10
        max_requests: 0
        max_clients: 20
        limit: 20
    site:
      cinder:
        enabled: false
        available: true
        type: wsgi
        name: cinder
        wsgi:
          daemon_process: cinder-wsgi
          processes: 5
          threads: 1
          user: cinder
          group: cinder
          display_name: '%{GROUP}'
          script_alias: '/ /usr/bin/cinder-wsgi'
          application_group: '%{GLOBAL}'
          authorization: 'On'
        host:
          address: 127.0.0.1
          name: 127.0.0.1
          port: 8776
        log:
          custom:
            format: >-
              %v:%p %{X-Forwarded-For}i %h %l %u %t \"%r\" %>s %D %O \"%{Referer}i\" \"%{User-Agent}i\"
          error:
            enabled: true
            format: '%M'
