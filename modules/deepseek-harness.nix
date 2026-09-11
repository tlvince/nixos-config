{
  pkgs,
  pkgsDsh,
  ...
}:
let
  # TODO: Drop dsh overrides
  # Issue URL: https://github.com/tlvince/nixos-config/issues/513
  # labels: module:dsh
  dsh = pkgsDsh.deepseek-harness.overrideAttrs (old: {
    # Treat dsh.filo.uk as loopback so nginx-proxied requests pass the
    # DNS-rebinding fence and the Settings mirror uses 'host' persistence
    # instead of 'memory' (see packages/client/connection/src/loopback-hostname.ts
    # and packages/client/ui-settings/src/client/index.ts: connection.isLoopback).
    postPatch = (old.postPatch or "") + ''
      substituteInPlace packages/client/connection/src/loopback-hostname.ts \
        --replace-fail "if (hostname === 'localhost' || hostname === '[::1]') return true" "if (hostname === 'localhost' || hostname === '[::1]' || hostname === 'dsh.filo.uk') return true"
    '';
  });
in
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

      locations."/plugins/events" = {
        extraConfig = ''
          proxy_read_timeout 1d;
          proxy_buffering off;
        '';
        proxyPass = "http://dsh";
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
      ExecStart = "${dsh}/bin/dsh web --host 127.0.0.1 --port 3080 --no-open --trusted-host dsh.filo.uk";
      Environment = [
        "DSH_TELEMETRY_DISABLED=true"
      ];
      Restart = "always";
      RestartSec = 5;
    };
  };
}
