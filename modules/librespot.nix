{
  config,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    (
      final: prev: {
        # TODO: Use upstream librespot package
        # Issue URL: https://github.com/tlvince/nixos-config/issues/332
        # https://github.com/NixOS/nixpkgs/pull/437539
        # https://github.com/librespot-org/librespot/issues/1527
        # labels: module:librespot, host:cm3588
        librespot = final.callPackage ../packages/librespot.nix {};
      }
    )
  ];

  systemd.services.librespot = {
    after = ["network.target" "sound.target"];
    description = "Librespot (an open source Spotify client)";
    documentation = ["https://github.com/librespot-org/librespot/wiki/Options"];
    wantedBy = ["multi-user.target"];
    wants = ["network.target" "sound.target"];
    script = "${pkgs.librespot}/bin/librespot --system-cache /var/lib/librespot --quiet \"%p@%H\"";
    serviceConfig = {
      DynamicUser = "yes";
      Restart = "on-failure";
      RestartSec = 10;
      SupplementaryGroups = ["audio" "librespot"];
    };
  };

  users.users.librespot = {
    createHome = true;
    group = "librespot";
    home = "/var/lib/librespot";
    isSystemUser = true;
  };

  users.groups.librespot = {};
}
