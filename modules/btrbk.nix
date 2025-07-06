{
  config,
  keys,
  lib,
  pkgs,
  ...
}: {
  services.btrbk = {
    instances = {
      btrbk = {
        onCalendar = "05:00";
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

  # TODO: nixos/btrbk: unsupported restrict-path ssh filter option
  # Remove when upstreamed, see https://github.com/NixOS/nixpkgs/issues/413678
  # labels: btrbk
  # Issue URL: https://github.com/tlvince/nixos-config/issues/305
  users.users.btrbk.openssh.authorizedKeys.keys = lib.mkForce [
    ''command="${pkgs.util-linux}/bin/ionice -t -c 2 ${pkgs.coreutils}/bin/nice -n 10 ${pkgs.btrbk}/share/btrbk/scripts/ssh_filter_btrbk.sh --sudo --delete --target --restrict-path /mnt/ichbiah/snapshots/framework",restrict ${keys.btrbk}''
  ];
}
