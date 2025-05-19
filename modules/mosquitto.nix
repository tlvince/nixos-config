{
  services.mosquitto = {
    enable = true;
    persistence = false;
    listeners = [
      {
        address = "127.0.0.1";
        omitPasswordAuth = true;
        settings = {
          allow_anonymous = true;
        };
      }
    ];
  };
}
