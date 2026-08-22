{
  config,
  pkgs,
  secretsPath,
  ...
}:
# TODO: Drop opencode override when updated in nixpkgs
# Issue URL: https://github.com/tlvince/nixos-config/issues/509
# labels: host:nea
let
  opencode =
    let
      base = pkgs.opencode.overrideAttrs (_: {
        version = "1.18.21";
        src = pkgs.fetchFromGitHub {
          owner = "anomalyco";
          repo = "opencode";
          tag = "v1.18.21";
          hash = "sha256-WKG/lts+wzDjYJ5pOZ0X4Kb0rJ1TzYQzQgjyQBY+bxs=";
        };
      });
    in
    base.overrideAttrs (old: {
      passthru = old.passthru // {
        node_modules = old.passthru.node_modules.overrideAttrs (_: {
          outputHash = "sha256-WqEZQCVl4oQFVbrhlWVaBW+JiSqjSK+LILPkDV9Avds=";
        });
      };
    });
in
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
    path = with pkgs; [
      fd
      gitMinimal
      ripgrep
      xdg-utils
    ];
    serviceConfig = {
      User = "tlv";
      ExecStart = "${opencode}/bin/opencode web --hostname 127.0.0.1 --port 4096";
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
