{
  config,
  pkgs,
  secretsPath,
  ...
}: {
  age.secrets.notify.file = "${secretsPath}/notify.age";

  systemd.services.barberd = {
    wantedBy = ["multi-user.target"];
    after = ["systemd-journald.socket"];
    serviceConfig = {
      BindReadOnlyPaths = ["/home/tlv/dev/barberd:/run/barberd"];
      ExecStart = "${pkgs.nodejs-slim}/bin/node --no-warnings=ExperimentalWarning /run/barberd/index.js";
      LoadCredential = "notify:${config.age.secrets.notify.path}";
      Restart = "on-failure";
      RestartSec = 10;
      SyslogIdentifier = "barberd";
      WorkingDirectory = "/run/barberd";
      RuntimeDirectory = "barberd";
      RuntimeDirectoryMode = "0755";

      # Reduce journal noise
      CPUAccounting = false;
      IOAccounting = false;
      IPAccounting = false;
      LogLevelMax = "warning";
      MemoryAccounting = false;
      TasksAccounting = false;

      # Hardening
      CapabilityBoundingSet = [""];
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
      RestrictAddressFamilies = "AF_INET";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      UMask = 077;
    };
  };

  systemd.timers.barberd = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5min";
      OnCalendar = "00..01,06..23:00/5";
      RandomizedDelaySec = "1min";
    };
  };
}
