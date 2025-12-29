{ pkgs, ... }:
{
  systemd.services.librespot = {
    after = [
      "network.target"
      "sound.target"
    ];
    description = "Librespot (an open source Spotify client)";
    documentation = [ "https://github.com/librespot-org/librespot/wiki/Options" ];
    wantedBy = [ "multi-user.target" ];
    wants = [
      "network.target"
      "sound.target"
    ];
    script = "${pkgs.librespot}/bin/librespot --system-cache /var/lib/librespot --quiet \"%p@%H\"";
    serviceConfig = {
      DynamicUser = "yes";
      Restart = "on-failure";
      RestartSec = 10;
      SupplementaryGroups = [
        "audio"
        "librespot"
      ];
    };
  };

  # Workaround eventual state errors, e.g.:
  # audio stream error: A backend-specific error has occurred: `alsa::poll()` returned POLLERR
  systemd.services.librespot-restart = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/systemctl restart librespot.service";
      Type = "oneshot";
    };
  };

  systemd.timers.librespot-restart = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 01:23:45";
    };
  };

  users.users.librespot = {
    createHome = true;
    group = "librespot";
    home = "/var/lib/librespot";
    isSystemUser = true;
  };

  users.groups.librespot = { };
}
