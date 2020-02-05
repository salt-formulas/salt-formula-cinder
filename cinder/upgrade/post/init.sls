cinder_post:
  test.show_notification:
    - text: "Running cinder.upgrade.post"

keystone_os_client_config_absent:
  file.absent:
    - name: /etc/openstack/clouds.yml
