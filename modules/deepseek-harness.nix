{
  pkgs,
  pkgsDsh,
  ...
}:
{
  services.nginx = {
    upstreams.dsh.servers."127.0.0.1:3080" = { };

    virtualHosts."dsh.filo.uk" = {
      forceSSL = true;
      useACMEHost = "filo.uk";

      locations."/" = {
        extraConfig = ''
          client_max_body_size 0;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        '';
        proxyPass = "http://dsh";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };

  systemd.services.dsh-web = {
    description = "DeepSeek Harness web server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [
      bash
      coreutils
      gitMinimal
      nix
    ];
    serviceConfig = {
      User = "tlv";
      ExecStart = "${pkgsDsh.deepseek-harness}/bin/dsh web --host 127.0.0.1 --port 3080 --no-open --trusted-host dsh.filo.uk";
      Environment = [
        "DSH_TELEMETRY_DISABLED=true"
      ];
      Restart = "always";
      RestartSec = 5;
    };
  };
}
