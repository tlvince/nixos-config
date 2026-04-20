{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  age.secrets.famlyd.file = "${secretsPath}/famlyd.age";

  systemd.services.famlyd = {
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      OnSuccess = "famlyd-etl.service";
      StartLimitBurst = 4;
      StartLimitIntervalSec = 60;
    };
    serviceConfig = {
      BindReadOnlyPaths = [ "/home/tlv/dev/famlyd:/run/famlyd" ];
      ExecStart = "${pkgs.bun}/bin/bun /run/famlyd/famlyd.js";
      StandardOutput = "append:/mnt/ichbiah/home/famlyd/calendar.jsonl";
      LoadCredential = "famlyd:${config.age.secrets.famlyd.path}";
      Restart = "on-failure";
      RestartSec = 5;
      SyslogIdentifier = "famlyd";
      Type = "oneshot";
      WorkingDirectory = "%t/famlyd";
      RuntimeDirectory = "famlyd";
      RuntimeDirectoryMode = "0755";
      RuntimeMaxSec = 9;

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

  systemd.timers.famlyd = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon..Fri 23:59:00";
      RandomizedDelaySec = "5s";
    };
  };
}
