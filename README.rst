=====
Usage
=====

Cinder provides an infrastructure for managing volumes in OpenStack.
Originally, this project was the Nova component called ``nova-volume``
and starting from the Folsom OpenStack release it has become an independent
project.

This file provides the sample configurations for different use cases:

* Pillar sample of a basic Cinder configuration:

  The pillar structure defines ``cinder-api`` and ``cinder-scheduler`` inside
  the ``controller`` role and ``cinder-volume`` inside the to ``volume``
  role.

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        version: juno
        cinder_uid: 304
        cinder_gid: 304
        nas_secure_file_permissions: false
        nas_secure_file_operations: false
        cinder_internal_tenant_user_id: f46924c112a14c80ab0a24a613d95eef
        cinder_internal_tenant_project_id: b7455b8974bb4064ad247c8f375eae6c
        default_volume_type: 7k2SaS
        enable_force_upload: true
        availability_zone_fallback: True
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: cinder
          user: cinder
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: cinder
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        backend:
          7k2_SAS:
            engine: storwize
            type_name: slow-disks
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS7K2
        audit:
          enabled: false
        osapi_max_limit: 500
        barbican:
          enabled: true

    cinder:
      volume:
        enabled: true
        version: juno
        cinder_uid: 304
        cinder_gid: 304
        nas_secure_file_permissions: false
        nas_secure_file_operations: false
        cinder_internal_tenant_user_id: f46924c112a14c80ab0a24a613d95eef
        cinder_internal_tenant_project_id: b7455b8974bb4064ad247c8f375eae6c
        default_volume_type: 7k2SaS
        enable_force_upload: true
        my_ip: 192.168.0.254
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: cinder
          user: cinder
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: cinder
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        backend:
          7k2_SAS:
            engine: storwize
            type_name: 7k2 SAS disk
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS7K2
        audit:
          enabled: false
        barbican:
          enabled: true


Volume vmware related options:

.. code-block:: yaml

    cinder:
      volume:
        backend:
          vmware:
            engine: vmware
            host_username: vmware
            host_password: vmware
            cluster_names: vmware_cluster01,vmware_cluster02

* The CORS parameters enablement:

  .. code-block:: yaml

    cinder:
      controller:
        cors:
          allowed_origin: https:localhost.local,http:localhost.local
          expose_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_methods: GET,PUT,POST,DELETE,PATCH
          allow_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_credentials: True
          max_age: 86400

* The client-side RabbitMQ HA setup for the controller:

  .. code-block:: yaml

      cinder:
        controller:
          ....
          message_queue:
            engine: rabbitmq
            members:
              - host: 10.0.16.1
              - host: 10.0.16.2
              - host: 10.0.16.3
            user: openstack
            password: pwd
            virtual_host: '/openstack'
          ....

* The client-side RabbitMQ HA setup for the volume component

  .. code-block:: yaml

     cinder:
       volume:
         ....
         message_queue:
           engine: rabbitmq
           members:
             - host: 10.0.16.1
             - host: 10.0.16.2
             - host: 10.0.16.3
           user: openstack
           password: pwd
           virtual_host: '/openstack'
         ....


* Configuring TLS communications.

  .. note:: By default, system-wide installed CA certs are used.
            Therefore, the ``cacert_file`` and ``cacert`` parameters are
            optional.

  * RabbitMQ TLS:

    .. code-block:: yaml

       cinder:
         controller, volume:
            message_queue:
              port: 5671
              ssl:
                enabled: True
                (optional) cacert: cert body if the cacert_file does not exists
                (optional) cacert_file: /etc/openstack/rabbitmq-ca.pem
                (optional) version: TLSv1_2

  * MySQL TLS:

    .. code-block:: yaml

       cinder:
         controller:
            database:
              ssl:
                enabled: True
                (optional) cacert: cert body if the cacert_file does not exists
                (optional) cacert_file: /etc/openstack/mysql-ca.pem

  * Openstack HTTPS API:

    .. code-block:: yaml

       cinder:
        controller, volume:
            identity:
               protocol: https
               (optional) cacert_file: /etc/openstack/proxy.pem
            glance:
               protocol: https
               (optional) cacert_file: /etc/openstack/proxy.pem

* Cinder setup with zeroing deleted volumes:

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        wipe_method: zero
        ...

* Cinder setup with shreding deleted volumes:

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        wipe_method: shred
        ...

* Configuration of ``policy.json`` file:

  .. code-block:: yaml

    cinder:
      controller:
        ....
        policy:
          'volume:delete': 'rule:admin_or_owner'
          # Add key without value to remove line from policy.json
          'volume:extend':

* Default Cinder backend ``lvm_type`` setup:

  .. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          # Type of LVM volumes to deploy; (default, thin, or auto). Auto defaults to thin if thin is supported.
          lvm_type: auto

* Default Cinder setup with iSCSI target:

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        version: mitaka
        default_volume_type: lvmdriver-1
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: cinder
          user: cinder
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: cinder
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        backend:
          lvmdriver-1:
            engine: lvm
            type_name: lvmdriver-1
            volume_group: cinder-volume

* Cinder setup for IBM Storwize:

  .. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          7k2_SAS:
            engine: storwize
            type_name: 7k2 SAS disk
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS7K2
          10k_SAS:
            engine: storwize
            type_name: 10k SAS disk
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS10K
          15k_SAS:
            engine: storwize
            type_name: 15k SAS
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS15K

* Cinder setup with NFS:

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        default_volume_type: nfs-driver
        backend:
          nfs-driver:
            engine: nfs
            type_name: nfs-driver
            volume_group: cinder-volume
            path: /var/lib/cinder/nfs
            devices:
            - 172.16.10.110:/var/nfs/cinder
            options: rw,sync

* Cinder setup with NetApp:

  .. code-block:: yaml

    cinder:
      controller:
        backend:
          netapp:
            engine: netapp
            type_name: netapp
            user: openstack
            vserver: vm1
            server_hostname: 172.18.2.3
            password: password
            storage_protocol: nfs
            transport_type: https
            lun_space_reservation: enabled
            use_multipath_for_image_xfer: True
            nas_secure_file_operations: false
            nas_secure_file_permissions: false
            devices:
              - 172.18.1.2:/vol_1
              - 172.18.1.2:/vol_2
              - 172.18.1.2:/vol_3
              - 172.18.1.2:/vol_4
    linux:
      system:
        package:
          nfs-common:
            version: latest

* Cinder setup with Hitachi VPS:

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        backend:
          hus100_backend:
            type_name: HUS100
            backend: hus100_backend
            engine: hitachi_vsp
            connection: FC

* Cinder setup with Hitachi VPS with defined ``ldev`` range:

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        backend:
          hus100_backend:
            type_name: HUS100
            backend: hus100_backend
            engine: hitachi_vsp
            connection: FC
            ldev_range: 0-1000

* Cinder setup with Ceph:

  .. code-block:: yaml

      cinder:
        controller:
          enabled: true
          backend:
            ceph_backend:
              type_name: standard-iops
              backend: ceph_backend
              pool: volumes
              engine: ceph
              user: cinder
              secret_uuid: da74ccb7-aa59-1721-a172-0006b1aa4e3e
              client_cinder_key: AQDOavlU6BsSJhAAnpFR906mvdgdfRqLHwu0Uw==
              report_discard_supported: True
              image_volume_cache_enabled: False

  .. note:: `Ceph official documentation <http://ceph.com/docs/master/rbd/rbd-openstack/>`__

* Cinder setup with HP3par:

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        backend:
          hp3par_backend:
            type_name: hp3par
            backend: hp3par_backend
            user: hp3paruser
            password: something
            url: http://10.10.10.10/api/v1
            cpg: OpenStackCPG
            host: 10.10.10.10
            login: hp3paradmin
            sanpassword: something
            debug: True
            snapcpg: OpenStackSNAPCPG

* Cinder setup with Fujitsu Eternus:

  .. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          10kThinPro:
            type_name: 10kThinPro
            engine: fujitsu
            pool: 10kThinPro
            host: 192.168.0.1
            port: 5988
            user: username
            password: pass
            connection: FC/iSCSI
            name: 10kThinPro
          10k_SAS:
            type_name: 10k_SAS
            pool: SAS10K
            engine: fujitsu
            host: 192.168.0.1
            port: 5988
            user: username
            password: pass
            connection: FC/iSCSI
            name: 10k_SAS

* Cinder setup with IBM GPFS filesystem:

  .. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          GPFS-GOLD:
            type_name: GPFS-GOLD
            engine: gpfs
            mount_point: '/mnt/gpfs-openstack/cinder/gold'
          GPFS-SILVER:
            type_name: GPFS-SILVER
            engine: gpfs
            mount_point: '/mnt/gpfs-openstack/cinder/silver'

* Cinder setup with HP LeftHand:

  .. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          HP-LeftHand:
            type_name: normal-storage
            engine: hp_lefthand
            api_url: 'https://10.10.10.10:8081/lhos'
            username: user
            password: password
            clustername: cluster1
            iscsi_chap_enabled: false

* Extra parameters for HP LeftHand:

  .. code-block:: yaml

    cinder type-key normal-storage set hplh:data_pl=r-10-2 hplh:provisioning=full

* Cinder setup with Solidfire:

  .. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          solidfire:
            type_name: normal-storage
            engine: solidfire
            san_ip: 10.10.10.10
            san_login: user
            san_password: password
            clustername: cluster1
            sf_emulate_512: false
            sf_api_port: 14443
            host: ctl01
            #for compatibility with old versions
            sf_account_prefix: PREFIX

* Cinder setup with Block Device driver:

  .. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          bdd:
            engine: bdd
            enabled: true
            type_name: bdd
            devices:
              - sdb
              - sdc
              - sdd

* Enable cinder-backup service for ceph

  .. code-block:: yaml

    cinder:
      controller:
        enabled: true
        version: mitaka
        backup:
          engine: ceph
          ceph_conf: "/etc/ceph/ceph.conf"
          ceph_pool: backup
          ceph_stripe_count: 0
          ceph_stripe_unit: 0
          ceph_user: cinder
          ceph_chunk_size: 134217728
          restore_discard_excess_bytes: false
      volume:
        enabled: true
        version: mitaka
        backup:
          engine: ceph
          ceph_conf: "/etc/ceph/ceph.conf"
          ceph_pool: backup
          ceph_stripe_count: 0
          ceph_stripe_unit: 0
          ceph_user: cinder
          ceph_chunk_size: 134217728
          restore_discard_excess_bytes: false

* Auditing filter (CADF) enablement:

  .. code-block:: yaml

    cinder:
      controller:
        audit:
          enabled: true
      ....
          filter_factory: 'keystonemiddleware.audit:filter_factory'
          map_file: '/etc/pycadf/cinder_api_audit_map.conf'
      ....
      volume:
        audit:
          enabled: true
      ....
          filter_factory: 'keystonemiddleware.audit:filter_factory'
          map_file: '/etc/pycadf/cinder_api_audit_map.conf'

* Cinder setup with custom availability zones:

  .. code-block:: yaml

    cinder:
      controller:
        default_availability_zone: my-default-zone
        storage_availability_zone: my-custom-zone-name
    cinder:
      volume:
        default_availability_zone: my-default-zone
        storage_availability_zone: my-custom-zone-name

  The ``default_availability_zone`` is used when a volume has been created,
  without specifying a zone in the ``create`` request as this zone must exist
  in your configuration.

  The ``storage_availability_zone`` is an actual zone where the node belongs to
  and must be specified per each node.

* Cinder setup with custom non-admin volume query filters:

  .. code-block:: yaml

    cinder:
      controller:
        query_volume_filters:
          - name
          - status
          - metadata
          - availability_zone
          - bootable

* ``public_endpoint`` and ``osapi_volume_base_url``:

  * ``public_endpoint``
     Used for configuring versions endpoint
  * ``osapi_volume_base_URL``
     Used to present Cinder URL to users

  These parameters can be useful when running Cinder under load balancer in
  SSL.

  .. code-block:: yaml

    cinder:
      controller:
        public_endpoint_address: https://${_param:cluster_domain}:8776

* Client role definition:

  .. code-block:: yaml

    cinder:
      client:
        enabled: true
        identity:
          host: 127.0.0.1
          port: 35357
          project: service
          user: cinder
          password: pwd
          protocol: http
          endpoint_type: internalURL
          region_name: RegionOne
        backend:
          ceph:
            type_name: standard-iops
            engine: ceph
            key:
              conn_speed: fibre-10G

* Barbican integration enablement:

  .. code-block:: yaml

    cinder:
      controller:
        barbican:
          enabled: true

* Keystone API version specification (v3 is default):

  .. code-block:: yaml

    cinder:
      controller:
        identity:
          api_version: v2.0

**Enhanced logging with logging.conf**

By default ``logging.conf`` is disabled.
You can enable per-binary ``logging.conf`` by setting the following
parameters:

* ``openstack_log_appender``
   Set to ``true`` to enable ``log_config_append`` for all OpenStack
   services

* ``openstack_fluentd_handler_enabled``
   Set to ``true`` to enable FluentHandler for all Openstack services

* ``openstack_ossyslog_handler_enabled``
   Set to ``true`` to enable OSSysLogHandler for all Openstack services

Only WatchedFileHandler, OSSysLogHandler, and FluentHandler are available.

To configure this functionality with pillar:

.. code-block:: yaml

  cinder:
    controller:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

    volume:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

Enable x509 and ssl communication between Cinder and Galera cluster.
---------------------
By default communication between Cinder and Galera is unsecure.

You able to set custom certificates in pillar:
controller:
  database:
    x509:
      enabled: True

volume:
  database:
    x509:
      enabled: True

cinder:
  controller:
    database:
      x509:
        cacert (certificate content)
        cert (certificate content)
        key (certificate content)
  volume:
    database:
      x509:
        cacert (certificate content)
        cert (certificate content)
        key (certificate content)

You can read more about it here:
    https://docs.openstack.org/security-guide/databases/database-access-control.html

Upgrades
========

Each openstack formula provide set of phases (logical bloks) that will help to
build flexible upgrade orchestration logic for particular components. The list
of phases and theirs descriptions are listed in table below:

+-------------------------------+------------------------------------------------------+
| State                         | Description                                          |
+===============================+======================================================+
| <app>.upgrade.service_running | Ensure that all services for particular application  |
|                               | are enabled for autostart and running                |
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.service_stopped | Ensure that all services for particular application  |
|                               | disabled for autostart and dead                      |
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.pkgs_latest     | Ensure that packages used by particular application  |
|                               | are installed to latest available version.           |
|                               | This will not upgrade data plane packages like qemu  |
|                               | and openvswitch as usually minimal required version  |
|                               | in openstack services is really old. The data plane  |
|                               | packages should be upgraded separately by `apt-get   |
|                               | upgrade` or `apt-get dist-upgrade`                   |
|                               | Applying this state will not autostart service.      |
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.render_config   | Ensure configuration is rendered actual version.     +
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.pre             | We assume this state is applied on all nodes in the  |
|                               | cloud before running upgrade.                        |
|                               | Only non destructive actions will be applied during  |
|                               | this phase. Perform service built in service check   |
|                               | like (keystone-manage doctor and nova-status upgrade)|
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.upgrade.pre     | Mostly applicable for data plane nodes. During this  |
|                               | phase resources will be gracefully removed from      |
|                               | current node if it is allowed. Services for upgraded |
|                               | application will be set to admin disabled state to   |
|                               | make sure node will not participate in resources     |
|                               | scheduling. For example on gtw nodes this will set   |
|                               | all agents to admin disable state and will move all  |
|                               | routers to other agents.                             |
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.upgrade         | This state will basically upgrade application on     |
|                               | particular target. Stop services, render             |
|                               | configuration, install new packages, run offline     |
|                               | dbsync (for ctl), start services. Data plane should  |
|                               | not be affected, only OpenStack python services.     |
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.upgrade.post    | Add services back to scheduling.                     |
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.post            | This phase should be launched only when upgrade of   |
|                               | the cloud is completed. Cleanup temporary files,     |
|                               | perform other post upgrade tasks.                    |
+-------------------------------+------------------------------------------------------+
| <app>.upgrade.verify          | Here we will do basic health checks (API CRUD        |
|                               | operations, verify do not have dead network          |
|                               | agents/compute services)                             |
+-------------------------------+------------------------------------------------------+


**Documentation and bugs**
======================
* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

* https://github.com/salt-formulas/salt-formula-cinder/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-cinder
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome
