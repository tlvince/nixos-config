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

  # https://github.com/NixOS/nixpkgs/blob/e60a96e293a6aa459d474193ba8eaee7bc761bc0/nixos/modules/services/web-apps/immich.nix#L328-L364
  systemd.services.postgresql-setup = lib.mkIf config.services.postgresql.enable {
    serviceConfig.ExecStartPost =
      let
        extensions = [
          "unaccent"
          "uuid-ossp"
          "cube"
          "earthdistance"
          "pg_trgm"
          "vector"
          "vchord"
        ];

        sqlFile = pkgs.writeText "immich-pgvectors-setup.sql" ''
          -- save previous version of vectorchord to trigger reindex on update
          SELECT COALESCE(installed_version, ''') AS vchord_version_before FROM pg_available_extensions WHERE name = 'vchord' \gset

          ${lib.concatMapStringsSep "\n" (ext: "CREATE EXTENSION IF NOT EXISTS \"${ext}\";") extensions}
          ${lib.concatMapStringsSep "\n" (ext: "ALTER EXTENSION \"${ext}\" UPDATE;") extensions}
          ALTER SCHEMA public OWNER TO ${cfg.database.user};

          -- trigger reindex if vectorchord updates
          -- https://docs.immich.app/administration/postgres-standalone/#updating-vectorchord
          SELECT COALESCE(installed_version, ''') AS vchord_version_after FROM pg_available_extensions WHERE name = 'vchord' \gset

          SELECT (:'vchord_version_before' != ''' AND :'vchord_version_before' != :'vchord_version_after') AS has_vchord_updated \gset
          \if :has_vchord_updated
            REINDEX INDEX face_index;
            REINDEX INDEX clip_index;
          \endif
        '';
      in
      [
        ''
          ${lib.getExe' cfg.database.package "psql"} -p "${toString cfg.database.port}" -d "${cfg.database.name}" -f "${sqlFile}"
        ''
      ];
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
