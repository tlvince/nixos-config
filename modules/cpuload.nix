{ pkgs, ... }:
{
  systemd.services.cpuload = {
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-journald.socket" ];
    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/timeout 30s ${pkgs.coreutils}/bin/sha1sum /dev/zero";
      Restart = "on-failure";
      RestartSec = 10;
      SuccessExitStatus = 124;
      SyslogIdentifier = "cpuload";

      # Hardening
      CapabilityBoundingSet = [ "" ];
      DynamicUser = true;
      KeyringMode = "private";
      LockPersonality = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      UMask = 077;
    };
  };

  systemd.timers.cpuload = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "6h";
    };
  };
}
