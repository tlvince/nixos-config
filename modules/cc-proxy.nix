{ pkgs, ... }:
{
  systemd.user.services.cc-proxy = {
    serviceConfig = {
      Environment = [
        "LOG_LEVEL_CONSOLE=warn"
        "PORT=48173"
      ];
      ExecStart = "${pkgs.nodejs-slim}/bin/node %h/dev/cc-proxy/bin/cli.js";
      Restart = "on-failure";
      RestartSec = 10;
      BindPaths = [ "%E/codex-claude-proxy" ];
      BindReadOnlyPaths = [ "%h/dev/cc-proxy" ];
      TemporaryFileSystem = [ "%h:ro" ];

      CapabilityBoundingSet = [ "" ];
      KeyringMode = "private";
      LockPersonality = true;
      PrivateDevices = true;
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
      UMask = 077;
    };
  };
}
