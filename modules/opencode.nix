{
  pkgs,
  ...
}:
let
  # Chromium needs an icon usable as "any" for a PWA to be installable.
  # "any maskable" will throw a warning, but quickest fix
  # https://web.dev/articles/maskable-icon#how
  pwaManifest = pkgs.writeText "site.webmanifest" (
    builtins.toJSON {
      name = "OpenCode";
      short_name = "OpenCode";
      id = "/";
      start_url = "/";
      scope = "/";
      display = "standalone";
      theme_color = "#080808";
      background_color = "#080808";
      icons = [
        {
          src = "/web-app-manifest-192x192.png";
          sizes = "192x192";
          type = "image/png";
          purpose = "any maskable";
        }
        {
          src = "/web-app-manifest-512x512.png";
          sizes = "512x512";
          type = "image/png";
          purpose = "any maskable";
        }
      ];
    }
  );

  # TODO: Drop opencode override when updated in nixpkgs
  # Issue URL: https://github.com/tlvince/nixos-config/issues/509
  # labels: host:nea
  opencode =
    let
      base = pkgs.opencode.overrideAttrs (old: {
        version = "1.18.21";
        # Reconnect SSE event stream after Android screen-lock freeze leaves
        # the fetch hanging on a half-open socket, and resync stale session
        # views on resume.
        patches = [ ./opencode-sse-freeze-resume.patch ];
        postPatch = (old.postPatch or "") + ''
          cp ${pwaManifest} packages/app/public/site.webmanifest
        '';
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
  services.nginx = {
    upstreams.opencode.servers."127.0.0.1:4096" = { };
    virtualHosts."opencode.filo.uk" = {
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
