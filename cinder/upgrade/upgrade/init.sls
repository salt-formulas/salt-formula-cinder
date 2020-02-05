cinder_upgrade:
  test.show_notification:
    - text: "Running cinder.upgrade.upgrade"

include:
 - cinder.upgrade.upgrade.pre
 - cinder.upgrade.service_stopped
 - cinder.upgrade.pkgs_latest
 - cinder.upgrade.render_config
 - cinder.db.offline_sync
 - cinder.upgrade.service_running
 - cinder.upgrade.upgrade.post
