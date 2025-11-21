{
  pkgs,
  pkgs-famly-fetch,
  secretsPath,
  ...
}: {
  systemd.user.services.famly-fetch = {
    script = ''
      set -euo pipefail
      # Source and export environment variables in systemd EnvironmentFile= format
      set -a
      source <(${pkgs.age}/bin/age -i $HOME/.ssh/config.d/tlvince/agenix -d ${secretsPath}/famly-fetch.age)
      set +a

      exec ${pkgs-famly-fetch.famly-fetch}/bin/famly-fetch --filename-pattern '%Y%m%d_%H%M%S_%ID' --journey --messages --notes --no-text-comments --pictures-folder $HOME/pictures/famly-fetch --state-file $XDG_STATE_HOME/famly-fetch.json --stop-on-existing
    '';
    serviceConfig = {
      Type = "oneshot";
      ReadWritePaths = [
        "%h/pictures/famly-fetch"
        "%S/famly-fetch.json"
      ];

      # Hardening
      CapabilityBoundingSet = [""];
      KeyringMode = "private";
      LockPersonality = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = ["AF_INET" "AF_UNIX"];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      UMask = 077;
    };
  };
}
