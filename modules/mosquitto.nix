{
  config,
  secretsPath,
  ...
}:
{
  age.secrets.mosquitto.file = "${secretsPath}/mosquitto.age";
  services.mosquitto = {
    enable = true;
    persistence = false;
    listeners = [
      {
        address = "127.0.0.1";
        users.root = {
          acl = [ "readwrite #" ];
          passwordFile = config.age.secrets.mosquitto.path;
        };
      }
    ];
  };
}
