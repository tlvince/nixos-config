{
  config,
  keys,
  ...
}: {
  services.btrbk = {
    instances = {
      btrbk = {
        onCalendar = "01:00";
        settings = {
          lockfile = "/var/lib/btrbk/btrbk.lock";
          timestamp_format = "long";

          snapshot_create = "onchange";
          snapshot_dir = "snapshots";

          archive_preserve = "30d *m";
          archive_preserve_min = "all";
          snapshot_preserve = "24h 7d 0w 0m 0y";
          snapshot_preserve_min = "latest";
          target_preserve = "0h 14d 6w 4m 1y";
          target_preserve_min = "latest";

          volume = {
            "/mnt/fowler" = {
              target = "/mnt/ichbiah/snapshots/fowler";
              subvolume = {
                "/" = {
                  snapshot_name = "root";
                };
                "/home" = {};
                "/var/log" = {
                  snapshot_name = "log";
                };
              };
            };

            "/mnt/ichbiah" = {
              subvolume = "home";
              snapshot_dir = "snapshots/ichbiah";
              snapshot_preserve = "24h 14d 6w 4m 1y";
            };
          };
        };
      };
    };
    sshAccess = [
      {
        key = keys.btrbk;
        roles = [
          "delete"
          "target"
        ];
      }
    ];
  };
}
