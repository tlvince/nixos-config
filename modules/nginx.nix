{
  services.nginx = {
    enable = true;

    recommendedBrotliSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts.default = {
      default = true;
      locations."/".return = 444;
      rejectSSL = true;
    };

    virtualHosts."test.filo.uk" = {
      useACMEHost = "filo.uk";
      forceSSL = true;
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
    };
  };

  users.users.nginx.extraGroups = ["acme"];
}
