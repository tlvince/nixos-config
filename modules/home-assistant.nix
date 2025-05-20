{config, ...}: {
  services.home-assistant = {
    enable = true;
    config = {
      automation = "!include automations.yaml";
      frontend = {};
      history = {};
      homeassistant = {
        country = "GB";
        elevation = "!secret elevation";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        name = "Home";
        time_zone = "Europe/London";
        unit_system = "metric";
      };
      http = {
        server_host = [
          "127.0.0.1"
        ];
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
        ];
      };
      recorder = {
        db_url = "sqlite:////dev/shm/home-assistant.db";
        purge_keep_days = 7;
        exclude = {
          domains = [
            "automations"
            "updater"
            "weblink"
          ];

          entities = [
            "sensor.date"
            "sensor.last_boot"
            "sun.sun"
            "weather.dark_sky"
            "weather.home"
          ];
        };
      };
      scene = "!include scenes.yaml";
      script = "!include scripts.yaml";
    };
    extraComponents = [
      "isal"
      "met"
      "mobile_app"
      "mqtt"
      "sun"
      "tplink"
    ];
  };

  services.nginx = {
    upstreams.home-assistant.servers."127.0.0.1:8123" = {};

    virtualHosts."home-assistant.filo.uk" = {
      forceSSL = true;
      useACMEHost = "filo.uk";

      locations."/" = {
        proxyPass = "http://home-assistant";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
