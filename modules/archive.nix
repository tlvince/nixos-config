{pkgs, ...}: let
  archive = pkgs.writeShellApplication {
    name = "archive";
    runtimeInputs = with pkgs; [
      btrbk
      sdparm
      systemd
      util-linux
    ];
    text = ''
      systemctl start systemd-cryptsetup@dijkstra.service
      mount -o compress=zstd,noatime /dev/mapper/dijkstra /mnt/dijkstra
      btrbk --config /dev/null archive /mnt/ichbiah/snapshots /mnt/dijkstra/snapshots
      systemctl stop systemd-cryptsetup@dijkstra.service
      sdparm --command=stop --readonly /dev/disk/by-uuid/e14d08e4-7123-4d86-bae0-b3de6f00454f
    '';
  };
in {
  systemd.services.archive = {
    description = "Archive btrbk snapshots";
    serviceConfig = {
      ExecStart = "${archive}/bin/archive";
      Type = "oneshot";
    };
  };
  systemd.timers.archive = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "05:30";
    };
  };
}
