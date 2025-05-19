{
  config,
  pkgs,
  ...
}: {
  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.zigbee2mqtt_2;
    settings = {
      advanced = {
        channel = 25;
        log_level = "warning";
        log_output = [
          "console"
        ];
        network_key = "!secrets.yaml network_key";
      };
      devices = "devices.yaml";
      frontend.enabled = false;
      groups = "groups.yaml";
      homeassistant.enabled = config.services.home-assistant.enable;
      ota.disable_automatic_update_check = true;
      permit_join = false;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://127.0.0.1:1883";
      };
      serial = {
        disable_led = true;
        port = "/dev/ttyACM0";
      };
      version = 4;
    };
  };
  systemd.services.zigbee2mqtt.after = ["mosquitto.service"];
}
