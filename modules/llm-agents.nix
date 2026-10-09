{
  jail-nix,
  pkgs,
  ...
}:
let
  jail = jail-nix.lib.init pkgs;
in
{
  environment.systemPackages = [
    (jail "pi" pkgs.pi-coding-agent (
      with jail.combinators;
      [
        mount-cwd
        network
        no-new-session # Allow SIGWINCH for terminal resizing, TIOCSTI disabled
        wayland # Clipboard
        (try-readwrite (noescape "~/.config/pi"))
        (set-env "PI_CODING_AGENT_DIR" "/home/tlv/.config/pi")
        (set-env "PI_SKIP_VERSION_CHECK" "1")
        (set-env "PI_TELEMETRY" "0")
        (add-pkg-deps (
          with pkgs;
          [
            fd
            ripgrep
            which
            wl-clipboard
          ]
        ))
      ]
    ))
  ];
}
