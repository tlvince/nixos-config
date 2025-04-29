{config, ...}: {
  services.btrbk.instances = {
    local = {
      snapshotOnly = true;
      settings = {
        lockfile = "/var/lib/btrbk/btrbk.lock";
        timestamp_format = "long";

        snapshot_create = "onchange";
        snapshot_dir = "snapshots";
        snapshot_preserve = "24h 7d 0w 0m 0y";
        snapshot_preserve_min = "latest";

        volume = {
          "/mnt/btrfs-root" = {
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
        };
      };
    };
  };
}
