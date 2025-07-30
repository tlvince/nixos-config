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
      systemctl start systemd-cryptsetup@eich.service
      mount -o compress=zstd,noatime /dev/mapper/eich /mnt/eich
      btrbk --config /dev/null archive /mnt/ichbiah/snapshots /mnt/eich/snapshots
      umount /mnt/eich
      systemctl stop systemd-cryptsetup@eich.service
      sdparm --command=stop --readonly /dev/disk/by-uuid/cb299988-72fa-42ae-91f2-593150f06c3f
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
