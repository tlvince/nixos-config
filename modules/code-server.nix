{ ... }:
{
  services.code-server = {
    enable = true;
    host = "127.0.0.1";
    port = 4444;
    auth = "none";
    user = "tlv";
    group = "users";
    disableTelemetry = true;
    disableUpdateCheck = true;
    disableWorkspaceTrust = true;
    disableGettingStartedOverride = true;
    extraArguments = [ "/home/tlv/.local/share/code-server/current" ];
  };

  services.nginx = {
    upstreams.code-server.servers."127.0.0.1:4444" = { };

    virtualHosts."code.filo.uk" = {
      forceSSL = true;
      useACMEHost = "filo.uk";

      locations."/" = {
        extraConfig = ''
          client_max_body_size 0;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        '';
        proxyPass = "http://code-server";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
