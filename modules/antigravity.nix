{
  jail,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    (
      jail "antigravity" pkgs.antigravity (with jail.combinators; [
        gpu
        gui
        network
        (persist-home "antigravity")
        # Add Wayland args
        (set-env "NIXOS_OZONE_WL" "1")
        # Prevent Electron forking the GUI
        (set-argv ["--wait" (noescape "\"$@\"")])
      ])
    )
  ];
}
