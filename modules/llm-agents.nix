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
    (jail "antigravity" pkgs.antigravity (
      with jail.combinators;
      [
        gpu
        gui
        network
        open-urls-in-browser
        (add-runtime ''
          SHELL=/bin/sh
          echo "root:x:0:0:System administrator:/root:$SHELL" > ~/.local/share/jail.nix/passwd
          echo "$(id -un):x:$(id -u):$(id -g)::$HOME:$SHELL" >> ~/.local/share/jail.nix/passwd
        '')
        (add-pkg-deps (
          with pkgs;
          [
            electron
            nodejs
            xdg-utils
          ]
        ))
        (persist-home "antigravity")
        # Add Wayland args
        (set-env "NIXOS_OZONE_WL" "1")
        # Prevent Electron forking the GUI
        (set-argv [
          "--wait"
          (noescape "\"$@\"")
        ])
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
