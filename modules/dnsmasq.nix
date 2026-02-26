{ secrets, ... }:
{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;
      bogus-priv = true;
      cache-size = 10000;
      domain-needed = true;
      filter-AAAA = true;
      interface = "enP4p65s0";
      listen-address = [ "192.168.0.2" ];
      local-ttl = 2;
      localise-queries = true;

      # Custom domain
      domain = "filo.uk";
      expand-hosts = true;
      local = "/filo.uk/";

      # Forwarding
      no-resolv = true;
      server = [
        # Upstreams
        "127.0.0.53"
        # Forwards
        "/photos.filo.uk/#"
        # Local only
        "/bind/"
        "/invalid/"
        "/localhost/"
        "/onion/"
        "/test/"
      ];

      # DHCP
      dhcp-authoritative = true;
      dhcp-host = secrets.dnsmasqHosts;
      dhcp-option = [
        "option:dns-server,0.0.0.0" # IP of dnsmasq host
        "option:domain-search,filo.uk"
        "option:router,192.168.0.1"
        "tag:block,option:router" # Remove gateway
      ];
      dhcp-range = "192.168.0.10,192.168.0.251,24h";

      # If a DHCP client claims that its name is "wpad", ignore that.
      # This fixes a security hole. see CERT Vulnerability VU#598349
      dhcp-name-match = "set:wpad-ignore,wpad";
      dhcp-ignore-names = "tag:wpad-ignore";
    };
  };

  networking.nameservers = [
    "2a07:a8c0::#${secrets.nextdns.cm3588}.dns.nextdns.io"
    "2a07:a8c1::#${secrets.nextdns.cm3588}.dns.nextdns.io"
    "45.90.28.0#${secrets.nextdns.cm3588}.dns.nextdns.io"
    "45.90.30.0#${secrets.nextdns.cm3588}.dns.nextdns.io"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve.DNSOverTLS = "true";
  };

  systemd.services.dnsmasq = {
    after = [ "systemd-networkd-wait-online.service" ];
    requires = [ "systemd-networkd-wait-online.service" ];
  };
}
