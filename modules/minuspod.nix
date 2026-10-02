{
  config,
  pkgsMinuspod,
  secretsPath,
  ...
}:
{
  age.secrets.minuspod.file = "${secretsPath}/minuspod.age";

  services.minuspod = {
    enable = true;
    package = pkgsMinuspod.minuspod;
    host = "127.0.0.1";
    port = 53918;
    baseUrl = "https://minuspod.filo.uk";
    environment = {
      GUNICORN_ACCESS_LOG = "";
      GUNICORN_LOG_LEVEL = "WARNING";
      LOG_LEVEL = "WARNING";
      MINUSPOD_TRUSTED_PROXY_COUNT = "1";
      WHISPER_BACKEND = "openai-api";
      WHISPER_DEVICE = "cpu";
    };
    environmentFile = config.age.secrets.minuspod.path;
  };

  services.nginx = {
    upstreams.minuspod.servers."127.0.0.1:53918" = { };

    virtualHosts."minuspod.filo.uk" = {
      forceSSL = true;
      useACMEHost = "filo.uk";
      locations."/" = {
        extraConfig = ''
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
        proxyPass = "http://minuspod";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
