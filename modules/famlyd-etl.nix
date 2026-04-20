{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  age.secrets.famlyd-etl.file = "${secretsPath}/famlyd-etl.age";

  systemd.services.famlyd-etl = {
    unitConfig = {
      StartLimitBurst = 4;
      StartLimitIntervalSec = 60;
    };
    serviceConfig = {
      BindReadOnlyPaths = [ "/home/tlv/dev/famlyd:/run/famlyd" ];
      ExecStart = "${pkgs.bun}/bin/bun /run/famlyd/famlyd-etl.js";
      LoadCredential = "famlyd-etl:${config.age.secrets.famlyd-etl.path}";
      Restart = "on-failure";
      RestartSec = 5;
      SyslogIdentifier = "famlyd-etl";
      WorkingDirectory = "%t/famlyd-etl";
      RuntimeDirectory = "famlyd-etl";
      RuntimeDirectoryMode = "0755";
      RuntimeMaxSec = 30;
      StateDirectory = "famlyd-etl";
      Environment = [
        "FAMLY_IMPORT_PATH=/mnt/ichbiah/home/famlyd/calendar.jsonl"
        "FAMLY_IMPORT_FAMILY_ID=Nw3xoEMzs7TpLoeqztwkdgQE9sG2"
      ];

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
}
