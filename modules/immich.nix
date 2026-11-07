{
  config,
  lib,
  pkgs,
  secrets,
  secretsPath,
  ...
}:
let
  cfg = config.services.immich;
in
{
  age.secrets.immich-smtp.file = "${secretsPath}/immich-smtp.age";

  services.immich = {
    enable = true;
    database = {
      enable = false; # Managed system-wide in modules/postgres.nix
      port = config.services.postgresql.settings.port;
    };
    environment = {
      IMMICH_ALLOW_SETUP = "false";
      IMMICH_LOG_LEVEL = "warn";
      TZ = config.time.timeZone;
    };
    mediaLocation = "/mnt/ichbiah/home/immich";
    redis = {
      enable = false; # Managed ourselves below
      host = config.services.redis.servers.immich.unixSocket;
    };
    settings = {
      backup = {
        database = {
          enabled = false;
        };
      };
      ffmpeg = {
        transcode = "disabled";
      };
      integrityChecks = {
        checksumFiles.cronExpression = "0 22 * * 0";
        missingFiles.cronExpression = "0 21 * * *";
        untrackedFiles.cronExpression = "30 21 * * *";
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
      notifications = {
        smtp = {
          enabled = true;
          from = "Immich Photo Server <noreply@filo.uk>";
          transport = {
            host = "smtp.eu.mailgun.org";
            password._secret = config.age.secrets.immich-smtp.path;
            port = 587;
            username = secrets.immichSmtpUsername;
          };
        };
      };
      server = {
        externalDomain = "https://my.immich.app";
      };
      storageTemplate = {
        enabled = true;
        hashVerificationEnabled = true;
        template = "{{y}}/{{MM}}/{{filename}}";
      };
    };
  };

  systemd.services.immich-server = {
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];

    serviceConfig.SupplementaryGroups = [
      config.services.redis.servers.immich.group
    ];
  };

  services.postgresql = {
    ensureDatabases = [ "immich" ];
    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
        ensureClauses.login = true;
      }
    ];
    extensions =
      ps: with ps; [
        pgvector
        vectorchord
      ];
    settings = {
      shared_preload_libraries = [ "vchord.so" ];
      search_path = "\"$user\", public, vectors";
    };
  };

  systemd.services.postgresql-setup = {
    serviceConfig.ExecStartPost = "${lib.getExe' cfg.database.package "psql"} -p ${toString cfg.database.port} -d ${cfg.database.name} -f ${cfg.database.setupSQL}";
  };

  services.redis.servers.immich = {
    enable = true;
    # Ephemeral
    appendOnly = false;
    save = [ ];
  };

  services.nginx = {
    upstreams.immich.servers."127.0.0.1:${toString config.services.immich.port}" = { };

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

          # https://github.com/immich-app/immich/pull/13543
          proxy_buffering off;
          proxy_request_buffering off;
        '';
        proxyPass = "http://immich";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
