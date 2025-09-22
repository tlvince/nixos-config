{
  config,
  secrets,
  ...
}: {
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
      listen-address = ["192.168.0.2"];
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
    # TODO: Restore NextDNS
    # Fixed in systemd >= 257.9
    # See: https://github.com/NixOS/nixpkgs/issues/440073
    # See: https://github.com/systemd/systemd/issues/38509
    # See: https://github.com/NixOS/nixpkgs/pull/440130
    # https://nixpk.gs/pr-tracker.html?pr=440130
    # labels: host:cm3588, systemd
    "1.1.1.1#cloudflare-dns.com"
    "1.0.0.1#cloudflare-dns.com"
  ];

  services.resolved = {
    enable = true;
    dnsovertls = "true";
  };
}
