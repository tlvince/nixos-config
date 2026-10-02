{ pkgs, ... }:
let
  archive = pkgs.writeShellApplication {
    name = "archive";
    runtimeInputs = with pkgs; [
      btrbk
      sdparm
      systemd
      util-linux
    ];
    text = ''
      systemctl start systemd-cryptsetup@joy.service
      mount -o compress=zstd,noatime /dev/mapper/joy /mnt/joy
      btrbk --config /dev/null archive /mnt/ichbiah/snapshots /mnt/joy/snapshots
      umount /mnt/joy
      systemctl stop systemd-cryptsetup@joy.service
      sdparm --command=stop --readonly /dev/disk/by-uuid/eb3670de-bb9d-4dac-b7d0-dc188814a3d2
    '';
  };
in
{
  systemd.services.archive = {
    description = "Archive btrbk snapshots";
    serviceConfig = {
      ExecStart = "${archive}/bin/archive";
      Type = "oneshot";
    };
  };
  systemd.timers.archive = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "05:30";
    };
  };
}
