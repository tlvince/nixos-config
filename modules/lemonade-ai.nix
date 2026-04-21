{
  config,
  lib,
  pkgs,
  pkgsLemonade ? pkgs,
  ...
}:
let
  cfg = config.services.lemonade-ai;
  defaultUser = "lemonade";
in
{
  options.services.lemonade-ai = {
    enable = lib.mkEnableOption "Lemonade AI server";

    package = lib.mkPackageOption pkgsLemonade "lemonade-ai" { };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "User account under which Lemonade runs.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The host address the Lemonade server should listen on.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "The port the Lemonade server should listen on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the configured port in the firewall.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "trace"
        "debug"
        "info"
        "warning"
        "error"
        "critical"
      ];
      default = "info";
      description = "Logging level passed to Lemonade.";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional environment variables for the Lemonade service.";
    };

    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/keys/lemonade-api-key";
      description = "Optional file containing the Lemonade API key.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.users = lib.mkIf (cfg.user == defaultUser) {
      "${defaultUser}" = {
        description = "Lemonade server daemon user";
        group = defaultUser;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.user == defaultUser) {
      "${defaultUser}" = { };
    };

    systemd.services.lemonade-ai = {
      description = "Lemonade Server";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      path = with pkgs; [
        gnutar
        procps
      ];

      environment = {
        HOME = "/var/lib/lemonade-ai";
        LEMONADE_HOST = cfg.host;
        LEMONADE_LOG_LEVEL = cfg.logLevel;
        LEMONADE_PORT = toString cfg.port;
      }
      // cfg.extraEnvironment;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/lemonade-server serve";
        User = cfg.user;

        KillSignal = "SIGINT";
        LimitMEMLOCK = "infinity";

        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "full";
        ProtectHome = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        LoadCredential = lib.optionalString (cfg.apiKeyFile != null) "LEMONADE_API_KEY:${cfg.apiKeyFile}";
        StateDirectory = "lemonade-ai";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
