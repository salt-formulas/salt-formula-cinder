cinder:
  volume:
    enabled: true
    version: liberty
    backend:
      7k2_SAS:
        engine: storwize
        type_name: 7k2_SAS
        host: 127.0.0.1
        port: 22
        user: username
        password: password
        connection: FC
        multihost: true
        multipath: true
        pool: SAS7K2
      10k_SAS:
        engine: storwize
        type_name: 10k_SAS
        host: 127.0.0.1
        port: 22
        user: username
        password: password
        connection: FC
        multihost: true
        multipath: true
        pool: SAS10K
      15k_SAS:
        engine: storwize
        type_name: 15k_SAS
        host: 127.0.0.1
        port: 22
        user: username
        password: password
        connection: FC
        multihost: true
        multipath: true
        pool: SAS15K
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
  controller:
    enabled: true
    version: liberty
    backend:
      7k2_SAS:
        engine: storwize
        type_name: 7k2_SAS
        host: 127.0.0.1
        port: 22
        user: username
        password: password
        connection: FC
        multihost: true
        multipath: true
        pool: SAS7K2
      10k_SAS:
        engine: storwize
        type_name: 10k_SAS
        host: 127.0.0.1
        port: 22
        user: username
        password: password
        connection: FC
        multihost: true
        multipath: true
        pool: SAS10K
      15k_SAS:
        engine: storwize
        type_name: 15k_SAS
        host: 127.0.0.1
        port: 22
        user: username
        password: password
        connection: FC
        multihost: true
        multipath: true
        pool: SAS15K
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
