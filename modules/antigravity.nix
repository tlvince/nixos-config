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
        open-urls-in-browser
        (add-runtime ''
          SHELL=/bin/sh
          echo "root:x:0:0:System administrator:/root:$SHELL" > ~/.local/share/jail.nix/passwd
          echo "$(id -un):x:$(id -u):$(id -g)::$HOME:$SHELL" >> ~/.local/share/jail.nix/passwd
        '')
        (add-pkg-deps (with pkgs; [
          electron
          nodejs
          xdg-utils
        ]))
        (persist-home "antigravity")
        # Add Wayland args
        (set-env "NIXOS_OZONE_WL" "1")
        # Prevent Electron forking the GUI
        (set-argv ["--wait" (noescape "\"$@\"")])
      ])
    )
  ];
}
