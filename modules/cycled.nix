{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  age.secrets.notify.file = "${secretsPath}/notify.age";

  systemd.services.cycled = {
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-journald.socket" ];
    serviceConfig = {
      BindReadOnlyPaths = [ "/home/tlv/dev/cycled:/run/cycled" ];
      ExecStart = "${pkgs.nodejs-slim}/bin/node --no-warnings=ExperimentalWarning /run/cycled/index.js";
      LoadCredential = "notify:${config.age.secrets.notify.path}";
      Restart = "on-failure";
      RestartSec = 10;
      SyslogIdentifier = "cycled";
      WorkingDirectory = "%S/cycled";
      RuntimeDirectory = "cycled";
      RuntimeDirectoryMode = "0755";
      RuntimeMaxSec = 60;
      StateDirectory = "cycled";

      # Reduce journal noise
      CPUAccounting = false;
      IOAccounting = false;
      IPAccounting = false;
      LogLevelMax = "warning";
      MemoryAccounting = false;
      TasksAccounting = false;

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

  systemd.timers.cycled = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnCalendar = "00..01,06..23:00/1";
      RandomizedDelaySec = "10";
    };
  };
}
