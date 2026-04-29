{
  config,
  pkgs,
  secretsPath,
  ...
}:
let
  mkServiceConfig = name: {
    BindReadOnlyPaths = [ "/home/tlv/dev/famlyd:/run/famlyd" ];
    ExecStart = "${pkgs.bun}/bin/bun /run/famlyd/${name}.js";
    Restart = "on-failure";
    RestartSec = 5;
    RuntimeDirectory = name;
    RuntimeDirectoryMode = "0755";
    SyslogIdentifier = name;
    WorkingDirectory = "%t/${name}";

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
in
{
  age.secrets = {
    famlyd.file = "${secretsPath}/famlyd.age";
    famlyd-etl.file = "${secretsPath}/famlyd-etl.age";
  };

  systemd.services.famlyd = {
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      OnSuccess = "famlyd-etl.service";
      StartLimitBurst = 4;
      StartLimitIntervalSec = 60;
    };
    serviceConfig = mkServiceConfig "famlyd" // {
      LoadCredential = "famlyd:${config.age.secrets.famlyd.path}";
      StandardOutput = "append:/mnt/ichbiah/home/famlyd/calendar.jsonl";
      TimeoutStartSec = 9;
      Type = "oneshot";
    };
  };

  systemd.services.famlyd-etl = {
    unitConfig = {
      StartLimitBurst = 4;
      StartLimitIntervalSec = 60;
    };
    serviceConfig = mkServiceConfig "famlyd-etl" // {
      Environment = [
        "FAMLY_IMPORT_FAMILY_ID=Nw3xoEMzs7TpLoeqztwkdgQE9sG2"
        "FAMLY_IMPORT_PATH=/mnt/ichbiah/home/famlyd/calendar.jsonl"
        "GOOGLE_APPLICATION_CREDENTIALS=%d/famlyd-etl"
      ];
      LoadCredential = "famlyd-etl:${config.age.secrets.famlyd-etl.path}";
      RuntimeMaxSec = 30;
      StateDirectory = "famlyd-etl";
    };
  };

  systemd.services.famlyd-backup = {
    unitConfig = {
      StartLimitBurst = 4;
      StartLimitIntervalSec = 60;
    };
    serviceConfig = mkServiceConfig "famlyd-backup" // {
      Environment = [
        "GOOGLE_APPLICATION_CREDENTIALS=%d/famlyd-backup"
      ];
      LoadCredential = "famlyd-backup:${config.age.secrets.famlyd-etl.path}";
      RuntimeMaxSec = 60;
      StandardOutput = "file:/mnt/ichbiah/home/famlyd/backup.jsonl";
    };
  };

  systemd.timers.famlyd = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon..Fri 23:59:00";
      RandomizedDelaySec = "5s";
    };
  };

  systemd.timers.famlyd-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "01:00";
      RandomizedDelaySec = "30s";
    };
  };
}
