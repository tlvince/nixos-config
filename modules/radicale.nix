{
  config,
  pkgs,
  secretsPath,
  ...
}: {
  age.secrets.radicale = {
    file = "${secretsPath}/radicale.age";
    mode = "770";
    owner = "nginx";
    group = "nginx";
  };

  services.radicale = {
    enable = true;
    rights = {
      root = {
        user = ".+";
        collection = "";
        permissions = "R";
      };
      principal = {
        user = ".+";
        collection = "{user}";
        permissions = "RW";
      };
      calendars = {
        user = ".+";
        collection = "{user}/[^/]+";
        permissions = "rw";
      };
    };
    settings = {
      auth = {
        type = "http_x_remote_user";
      };
      logging = {
        level = "warning";
      };
      server = {
        hosts = ["127.0.0.1:5232"];
      };
      storage = {
        filesystem_folder = "/mnt/ichbiah/home/radicale/collections";
        hook = "${pkgs.git}/bin/git add -A && (${pkgs.git}/bin/git diff --cached --quiet || ${pkgs.git}/bin/git -c user.name=%(user)s -c user.email=radicale-%(user)s@filo.uk commit -m \"Changes by \"%(user)s)";
      };
      web = {
        type = "none";
      };
    };
  };

  services.nginx = {
    upstreams.radicale.servers."127.0.0.1:5232" = {};

    virtualHosts."radicale.filo.uk" = {
      basicAuthFile = config.age.secrets.radicale.path;
      forceSSL = true;
      useACMEHost = "filo.uk";

      locations."/radicale" = {
        extraConfig = ''
          proxy_set_header X-Script-Name /radicale;
          proxy_set_header X-Remote-User $remote_user;
        '';
        proxyPass = "http://radicale";
        recommendedProxySettings = true;
      };
    };
  };
}
