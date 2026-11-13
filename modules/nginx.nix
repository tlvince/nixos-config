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
  };
}
