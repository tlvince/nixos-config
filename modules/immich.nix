{
  config,
  pkgs-immich,
  ...
}: {
  services.immich = {
    enable = true;
    database.enable = false;
    environment = {
      IMMICH_LOG_LEVEL = "warn";
      TZ = config.time.timeZone;
    };
    mediaLocation = "/mnt/ichbiah/home/immich";
    redis = {
      # Managed ourselves
      enable = false;
      host = config.services.redis.servers.immich.unixSocket;
    };
    # TODO: aarch64 build broken in master. Remove when merged.
    # https://github.com/NixOS/nixpkgs/pull/404977
    # https://github.com/NixOS/nixpkgs/issues/404089
    # https://hydra.nixos.org/build/295418020
    package = pkgs-immich.immich;
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
        externalDomain = "https://immich.filo.uk";
      };
      storageTemplate = {
        enabled = true;
        hashVerificationEnabled = true;
        template = "{{y}}/{{MM}}/{{filename}}";
      };
    };
  };

  services.postgresql = {
    ensureDatabases = ["immich"];
    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
    ];
    extensions = ps: with ps; [pgvecto-rs];
    settings = {
      shared_preload_libraries = ["vectors.so"];
      search_path = "\"$user\", public, vectors";
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

    virtualHosts."immich.filo.uk" = {
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
