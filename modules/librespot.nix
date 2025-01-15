{
  config,
  pkgs,
  ...
}: {
  systemd.services.librespot = {
    after = ["network.target" "sound.target"];
    description = "Librespot (an open source Spotify client)";
    documentation = "https://github.com/librespot-org/librespot";
    documentation = "https://github.com/librespot-org/librespot/wiki/Options";
    wantedBy = ["multi-user.target"];
    wants = ["network.target" "sound.target"];
    script = "${pkgs.librespot}/bin/librespot \"%p@%H\"";
    serviceConfig = {
      DynamicUser = "yes";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
