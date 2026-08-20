{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  age.secrets.caltrack.file = "${secretsPath}/caltrack.age";

  systemd.services.caltrack = {
    description = "caltrack photo calorie tracker";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "systemd-tmpfiles-setup.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      BindReadOnlyPaths = [ "/home/tlv/dev/caltrack:/run/caltrack" ];
      Environment = [
        "DATA_DIR=/var/lib/caltrack"
        "HOST=127.0.0.1"
        "PORT=6739"
      ];
      ExecStart = "${pkgs.nodejs}/bin/node /run/caltrack/server/server.js";
      LoadCredential = "caltrack:${config.age.secrets.caltrack.path}";
      Restart = "on-failure";
      RestartSec = 10;
      StateDirectory = "caltrack";
      SyslogIdentifier = "caltrack";
      TimeoutStopSec = 10;
      WorkingDirectory = "/run/caltrack";

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

  services.nginx = {
    upstreams.caltrack.servers."127.0.0.1:6739" = { };

    virtualHosts."caltrack.filo.uk" = {
      forceSSL = true;
      useACMEHost = "filo.uk";
      locations."/" = {
        extraConfig = ''
          client_max_body_size 20m;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        '';
        proxyPass = "http://caltrack";
        recommendedProxySettings = true;
      };
    };
  };
}
