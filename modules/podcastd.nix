{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  # Secrets file (create with agenix) in systemd EnvironmentFile= format:
  #   OPENAI_API_KEY=...
  #   OPENAI_BASE_URL=... (optional, defaults to local Ollama)
  #   OPENAI_MODEL=... (optional)
  #   TRANSCRIBE_BASE_URL=... (optional, falls back to OPENAI_BASE_URL)
  #   TRANSCRIBE_API_KEY=... (optional, falls back to OPENAI_API_KEY)
  #   TRANSCRIBE_MODEL=... (optional)
  # Feed enclosure URLs follow the request host, so no public-URL setting exists.
  age.secrets.podcastd.file = "${secretsPath}/podcastd.age";

  systemd.services.podcastd = {
    description = "podcastd ad-stripping podcast proxy";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "systemd-tmpfiles-setup.service"
    ];
    wants = [ "network-online.target" ];
    path = [ pkgs.ffmpeg-headless ];
    serviceConfig = {
      # Repo checkout, read-only; feeds managed at ~/dev/podcastd/config/feeds.json
      BindReadOnlyPaths = [ "/home/tlv/dev/podcastd:/run/podcastd" ];
      Environment = [
        "PORT=6740"
        "DATA_DIR=%S/podcastd"
        "CACHE_DIR=%C/podcastd"
      ];
      EnvironmentFile = config.age.secrets.podcastd.path;
      ExecStart = "${pkgs.nodejs_24}/bin/node /run/podcastd/src/server.js";
      Restart = "on-failure";
      RestartSec = 10;
      StateDirectory = "podcastd";
      CacheDirectory = "podcastd";
      SyslogIdentifier = "podcastd";
      TimeoutStopSec = 10;
      WorkingDirectory = "/run/podcastd";

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
    upstreams.podcastd.servers."127.0.0.1:6740" = { };

    virtualHosts."podcasts.filo.uk" = {
      forceSSL = true;
      useACMEHost = "filo.uk";
      locations."/" = {
        extraConfig = ''
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
        proxyPass = "http://podcastd";
        recommendedProxySettings = true;
      };
    };
  };
}
