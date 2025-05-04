{
  config,
  pkgs-6fc3feb,
  ...
}: {
  services.immich = {
    enable = true;
    environment = {
      IMMICH_LOG_LEVEL = "warn";
      TZ = config.time.timeZone;
    };
    redis = {
      # Managed ourselves
      enable = false;
      host = config.services.redis.servers.immich.unixSocket;
    };
    package = pkgs-6fc3feb.immich;
    settings = {
      backup = {
        database = {
          enabled = false;
        };
      };
      ffmpeg = {
        transcode = "disabled";
      };
      library = {
        scan = {
          cronExpression = "0 3 * * *";
          enabled = true;
        };
      };
      logging = {
        enabled = true;
        level = "warn";
      };
      newVersionCheck = {
        enabled = false;
      };
      server = {
        externalDomain = "https://immich-next.filo.uk";
      };
      storageTemplate = {
        enabled = true;
        hashVerificationEnabled = true;
        template = "{{y}}/{{MM}}/{{filename}}";
      };
    };
  };

  services.redis.servers.immich = {
    enable = true;
    # Ephemeral
    appendOnly = false;
    save = [];
  };

  systemd.services.immich-server.serviceConfig.SupplementaryGroups = [
    config.services.redis.servers.immich.group
  ];

  services.nginx = {
    upstreams.immich.servers."127.0.0.1:${toString config.services.immich.port}" = {};

    virtualHosts."immich-next.filo.uk" = {
      useACMEHost = "filo.uk";
      forceSSL = true;

      locations."/" = {
        extraConfig = ''
          # allow large file uploads
          client_max_body_size 5000M;

          # set timeout
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout       600s;
        '';
        proxyPass = "http://immich";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
