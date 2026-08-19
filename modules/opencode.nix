{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  age.secrets.opencode = {
    file = "${secretsPath}/opencode.age";
    mode = "640";
    owner = "nginx";
    group = "nginx";
  };

  services.nginx = {
    upstreams.opencode.servers."127.0.0.1:4096" = { };
    virtualHosts."opencode.filo.uk" = {
      basicAuthFile = config.age.secrets.opencode.path;
      forceSSL = true;
      useACMEHost = "filo.uk";

      locations."/" = {
        extraConfig = ''
          client_max_body_size 0;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        '';
        proxyPass = "http://opencode";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };

  systemd.services.opencode-web = {
    description = "opencode web server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.xdg-utils ];
    serviceConfig = {
      User = "tlv";
      ExecStart = "${pkgs.opencode}/bin/opencode web --hostname 127.0.0.1 --port 4096";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "OPENCODE_DISABLE_AUTOUPDATE=true"
        "OPENCODE_DISABLE_DEFAULT_PLUGINS=true"
        "OPENCODE_DISABLE_LSP_DOWNLOAD=true"
      ];
    };
  };
}
