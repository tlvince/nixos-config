{
  config,
  pkgs,
  secretsPath,
  ...
}: {
  age.secrets.notify.file = "${secretsPath}/notify.age";

  systemd.services.redditd = {
    wantedBy = ["multi-user.target"];
    after = ["systemd-journald.socket"];
    serviceConfig = {
      BindPaths = ["/home/tlv/dev/redditd/state.json:/run/redditd/state.json"];
      BindReadOnlyPaths = ["/home/tlv/dev/redditd:/run/redditd"];
      ExecStart = "${pkgs.nodejs}/bin/node --no-warnings=ExperimentalWarning /run/redditd/index.js";
      LoadCredential = "notify:${config.age.secrets.notify.path}";
      Restart = "on-failure";
      RestartSec = 10;
      SyslogIdentifier = "redditd";
      WorkingDirectory = "/run/redditd";
      RuntimeDirectory = "redditd";
      RuntimeDirectoryMode = "0755";

      # Reduce journal noise
      CPUAccounting = false;
      IOAccounting = false;
      IPAccounting = false;
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

  systemd.timers.redditd = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5min";
      OnCalendar = "00..01,06..23:00/1";
      RandomizedDelaySec = 10;
    };
  };
}
