cinder:
  controller:
    enabled: true
    version: liberty
    backend:
      ceph_backend:
        backend_host: ceph
        type_name: standard-iops
        backend: ceph_backend
        pool: volumes
        engine: ceph
        user: cinder
        secret_uuid: password
        client_cinder_key: password
        image_volume_cache_enabled: true
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: cinder
      password: pwd
      region: regionOne
    osapi:
      host: 127.0.0.1
    osapi_max_limit: 500
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
    default_volume_type: 7k2SaS
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: pwd
      virtual_host: '/openstack'
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: cinder
      user: cinder
      password: pwd
    policy:
      'volume:delete': 'rule:admin_or_owner'
      'volume:extend':
  volume:
    enabled: true
    version: liberty
    backend:
      ceph_backend:
        backend_host: ceph
        type_name: standard-iops
        backend: ceph_backend
        pool: volumes
        engine: ceph
        user: cinder
        secret_uuid: password
        client_cinder_key: password
        rbd_exclusive_cinder_pool: true
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: cinder
      password: pwd
      region: regionOne
    osapi:
        host: 127.0.0.1
    glance:
        host: 127.0.0.1
        port: 9292
    default_volume_type: 7k2SaS
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: pwd
      virtual_host: '/openstack'
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: cinder
      user: cinder
      password: pwd
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
