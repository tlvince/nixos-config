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
    (jail "opencode" pkgs.opencode (
      with jail.combinators;
      [
        mount-cwd
        network
        no-new-session # Allow SIGWINCH for terminal resizing, TIOCSTI disabled
        wayland # Clipboard
        (fwd-env "XDG_CACHE_HOME")
        (fwd-env "XDG_CONFIG_HOME")
        (fwd-env "XDG_DATA_HOME")
        (fwd-env "XDG_STATE_HOME")
        (try-readwrite (noescape "~/.cache/opencode"))
        (try-readwrite (noescape "~/.config/opencode"))
        (try-readwrite (noescape "~/.local/share/opencode"))
        (try-readwrite (noescape "~/.local/state/opencode"))
        (set-env "OPENCODE_DISABLE_AUTOUPDATE" "true")
        (set-env "OPENCODE_DISABLE_DEFAULT_PLUGINS" "true")
        (set-env "OPENCODE_DISABLE_LSP_DOWNLOAD" "true")
        (add-pkg-deps (
          with pkgs;
          [
            bun
            git
            less
            ripgrep
            wl-clipboard
          ]
        ))
      ]
    ))
    (jail "pi" pkgs.pi-coding-agent (
      with jail.combinators;
      [
        mount-cwd
        network
        no-new-session # Allow SIGWINCH for terminal resizing, TIOCSTI disabled
        (try-readwrite (noescape "~/.config/pi"))
        (set-env "PI_CODING_AGENT_DIR" "/home/tlv/.config/pi")
        (set-env "PI_OFFLINE" "true")
        (add-pkg-deps (
          with pkgs;
          [
            fd
            ripgrep
          ]
        ))
      ]
    ))
  ];
}
