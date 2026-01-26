{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  age.secrets.webdav = {
    file = "${secretsPath}/webdav.age";
    mode = "640";
    owner = "nginx";
    group = "nginx";
  };

  services.nginx = {
    additionalModules = [ pkgs.nginxModules.dav ];
    virtualHosts."webdav.filo.uk" = {
      basicAuthFile = config.age.secrets.webdav.path;
      forceSSL = true;
      useACMEHost = "filo.uk";

      locations."/" = {
        root = "/mnt/ichbiah/home/webdav";
        extraConfig = ''
          client_max_body_size 0;
          create_full_put_path on;
          dav_methods PUT DELETE MKCOL COPY MOVE;
          dav_ext_methods PROPFIND OPTIONS;
        '';
      };
    };
  };

  systemd.services.nginx.serviceConfig = {
    ReadWritePaths = [ "/mnt/ichbiah/home/webdav" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/ichbiah/home/webdav 0755 nginx nginx -"
  ];
}
