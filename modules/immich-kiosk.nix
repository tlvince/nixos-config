{
  config,
  lib,
  pkgs,
  pkgs-immich-kiosk,
  secretsPath,
  ...
}: {
  age.secrets.immich-kiosk = {
    file = "${secretsPath}/immich-kiosk.age";
    mode = "770";
    owner = "nginx";
    group = "nginx";
  };

  age.secrets.immich-kiosk-api-key.file = "${secretsPath}/immich-kiosk-api-key.age";

  systemd.services.immich-kiosk = {
    wantedBy = ["multi-user.target"];
    after = ["immich-server.service"];
    environment = {
      KIOSK_ALBUMS = lib.strings.concatStringsSep ", " [
        "4fa933cf-051f-4621-9ac7-8d06776c261c"
        "6466548c-4995-4fb5-ab1f-f63cc9ff3e5f"
      ];
      KIOSK_BEHIND_PROXY = "true";
      KIOSK_DISABLE_SCREENSAVER = "true";
      KIOSK_DISABLE_UI = "true";
      KIOSK_DURATION = "30";
      KIOSK_IMAGE_FIT = "cover";
      KIOSK_IMMICH_URL = "https://immich.filo.uk/";
      KIOSK_LAYOUT = "splitview";
      KIOSK_PORT = "5291";
      KIOSK_SLEEP_DIM_SCREEN = "true";
      KIOSK_SLEEP_END = "07";
      KIOSK_SLEEP_ICON = "true";
      KIOSK_SLEEP_START = "00";
      KIOSK_TRANSITION = "cross-fade";
    };
    # TODO: Remove immich-kiosk credentials wrapper
    # Issue URL: https://github.com/tlvince/nixos-config/issues/354
    # See https://github.com/damongolding/immich-kiosk/discussions/553
    # labels: module:immich-kiosk
    script = ''
      export KIOSK_IMMICH_API_KEY=$(cat "$CREDENTIALS_DIRECTORY/immich-kiosk-api-key")
      exec ${pkgs-immich-kiosk.immich-kiosk}/bin/immich-kiosk
    '';
    serviceConfig = {
      LoadCredential = "immich-kiosk-api-key:${config.age.secrets.immich-kiosk-api-key.path}";
      Restart = "on-failure";
      RestartSec = 10;
      RuntimeDirectory = "immich-kiosk";
      SyslogIdentifier = "immich-kiosk";
      WorkingDirectory = "/run/immich-kiosk";

      # Hardening
      CapabilityBoundingSet = [""];
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
      RestrictAddressFamilies = "AF_INET";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      UMask = 077;
    };
  };
  services.nginx = {
    upstreams.immich-kiosk.servers."127.0.0.1:5291" = {};
    virtualHosts."immich-kiosk.filo.uk" = {
      basicAuthFile = config.age.secrets.immich-kiosk.path;
      useACMEHost = "filo.uk";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://immich-kiosk";
        recommendedProxySettings = true;
      };
    };
  };
}
