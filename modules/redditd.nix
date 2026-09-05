{
  config,
  pkgs,
  secretsPath,
  ...
}:
let
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.curl-cffi
  ]);
in
{
  age.secrets.notify.file = "${secretsPath}/notify.age";

  systemd.services.redditd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      BindReadOnlyPaths = [ "/home/tlv/dev/redditd:/run/redditd" ];
      ExecStart = "${pythonEnv}/bin/python /run/redditd/redditd.py --state %S/redditd/state.json";
      LoadCredential = "notify:${config.age.secrets.notify.path}";
      Restart = "on-failure";
      RestartSec = 10;
      StateDirectory = "redditd";
      SyslogIdentifier = "redditd";
      WorkingDirectory = "/run/redditd";

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
      UMask = "0077";
    };
  };
}
