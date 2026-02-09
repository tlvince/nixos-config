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
            git
            less
            ripgrep
            wl-clipboard
          ]
        ))
      ]
    ))
    (jail "yolo-codex" pkgs.codex (
      with jail.combinators;
      [
        mount-cwd
        network
        (add-pkg-deps (
          with pkgs;
          [
            # https://github.com/numtide/llm-agents.nix/blob/b6f6693bc2b970af3d2220845d13009c63faad2f/packages/claudebox/default.nix#L7-L21
            curl
            fd
            findutils
            gawk
            git
            gnugrep
            gnused
            jq
            less
            nix
            python3
            ripgrep
            tree
            wget
            which
          ]
        ))
        (set-argv [
          "--dangerously-bypass-approvals-and-sandbox"
          (noescape "\"$@\"")
        ])
        (try-readwrite (noescape "~/.codex"))
      ]
    ))
  ];
}
