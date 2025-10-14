{
  config,
  lib,
  pkgs,
  pkgs-master,
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

  services.immich-kiosk = {
    enable = true;
    immichUrl = "https://immich.filo.uk/";
    immichApiKeyFile = config.age.secrets.immich-kiosk-api-key.path;
    port = 5291;
    settings = {
      albums = [
        "4fa933cf-051f-4621-9ac7-8d06776c261c"
        "6466548c-4995-4fb5-ab1f-f63cc9ff3e5f"
      ];
      behind_proxy = true;
      disable_ui = true;
      duration = 30;
      image_fit = "cover";
      layout = "splitview";
      sleep_dim_screen = true;
      sleep_end = "07";
      sleep_icon = true;
      sleep_start = "00";
      transition = "cross-fade";
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
