{
  pkgs,
  pkgsDsh,
  ...
}:
let
  # TODO: Drop dsh overrides when upstream widens platforms
  # The PR restricts deepseek-harness to x86_64-linux, but nea is
  # aarch64-linux. The PR author built on aarch64-linux, just didn't verify.
  # The pnpmDeps hash also differs on aarch64 due to optional native deps.
  # Issue URL: https://github.com/tlvince/nixos-config/issues/513
  # See: https://github.com/NixOS/nixpkgs/pull/554081
  # labels: module:dsh
  dsh = pkgsDsh.deepseek-harness.overrideAttrs (old: {
    # Treat dsh.filo.uk as loopback so nginx-proxied requests pass the
    # DNS-rebinding fence and the Settings mirror uses 'host' persistence
    # instead of 'memory' (see packages/client/connection/src/loopback-hostname.ts
    # and packages/client/ui-settings/src/client/index.ts: connection.isLoopback).
    postPatch = (old.postPatch or "") + ''
      substituteInPlace packages/client/connection/src/loopback-hostname.ts \
        --replace-fail "if (hostname === 'localhost' || hostname === '[::1]') return true" "if (hostname === 'localhost' || hostname === '[::1]' || hostname === 'dsh.filo.uk') return true"
      patch -p1 < ${../patches/deepseek-harness/dsh-browser-open.patch}
      patch -p1 < ${../patches/deepseek-harness/dsh-bash-retry.patch}
    '';
    pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
      outputHash = "sha256-+PsdK9u3ZKv4XtSc8tBKKP48J/95/CGTMIUf8Q8dbok=";
    });
    meta = old.meta // {
      platforms = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
  });
in
{
  # Offline highlight.js assets for browser-open plugin
  environment.etc."dsh-browser-open/hljs.min.js".source =
    ../patches/deepseek-harness/dsh-browser-open.hljs.min.js;
  environment.etc."dsh-browser-open/hljs.min.css".source =
    ../patches/deepseek-harness/dsh-browser-open.hljs.min.css;

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
      ExecStart = "${dsh}/bin/dsh web --host 127.0.0.1 --port 3080 --no-open --trusted-host dsh.filo.uk";
      Environment = [
        "DSH_TELEMETRY_DISABLED=true"
      ];
      Restart = "always";
      RestartSec = 5;
    };
  };
}
