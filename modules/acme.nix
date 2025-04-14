{
  age.secrets.dns.file = ../secrets/dns.age;

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@filo.uk";
    certs = {
      "filo.uk" = {
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        domain = "filo.uk";
        environmentFile = "/run/agenix/dns";
        extraDomainNames = ["*.filo.uk"];
      };
    };
  };
}
