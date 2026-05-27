{ ... }:
{
  systemd.user.services.g-proxy = {
    serviceConfig = {
      WorkingDirectory = "%h/dev/g-proxy";
      ExecStart = "%h/dev/g-proxy/server/.venv/bin/python server/src/run.py";
      Restart = "on-failure";
      RestartSec = 10;
      BindReadOnlyPaths = [ "%h/dev/g-proxy" ];
      TemporaryFileSystem = [ "%h:ro" ];

      CapabilityBoundingSet = [ "" ];
      KeyringMode = "private";
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
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
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };
}
