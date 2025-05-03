{config, ...}: {
  services.dnsmasq = {
    enable = true;
    settings = {
      bogus-priv = true;
      cache-size = 10000;
      domain-needed = true;
      filter-AAAA = true;
      interface = "enP4p65s0";
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
        "1.1.1.1"
        "1.0.0.1"
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
      #dhcp-authoritative
      dhcp-option = [
        "option:dns-server,0.0.0.0"
        "option:router,192.168.0.1"
      ];
      dhcp-range = "192.168.0.10,192.168.0.251,24h";

      # If a DHCP client claims that its name is "wpad", ignore that.
      # This fixes a security hole. see CERT Vulnerability VU#598349
      dhcp-name-match = "set:wpad-ignore,wpad";
      dhcp-ignore-names = "tag:wpad-ignore";

      # Adblock
      address = [
        "/aws.adobess.com/#"
        "/beacon-v2.helpscout.net/#"
        "/blueistheneworanges.com/#"
        "/graph.facebook.com/#"
        "/ingest.sentry.io/#"
        "/metrics.icloud.com/#"
        "/privatestats.whatsapp.net/#"
        "/t.premii.com/#"
        "/telemetry.algolia.com/#"
        "/track.miro.com/#"
        "/uk-tracking.nextdoor.com/#"
        "/usage.influxdata.com/#"

        # Barclays
        "/aimatch.com/#"
        "/aimatch.net/#"

        # Revolut
        "/appsflyer.com/#"
        "/appsflyersdk.com/#"

        # Smart Plug
        "/tplinkcloud.com/#"
        "/tplinkra.com/#"

        # Brave
        "/ads-serve.brave.com/#"
        "/ads-static.brave.com/#"
        "/laptop-updates.brave.com/#"
        "/mainnet-infura.brave.com/#"
        "/p3a.brave.com/#"
        "/rewards.brave.com/#"
        "/variations.brave.com/#"

        # HP Printer
        "/hpeprint.com/#"
        "/www1.hp.com/#"
        "/www2.hp.com/#"
      ];
    };
  };

  services.resolved.enable = false;
}
