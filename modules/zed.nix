{
  pkgs,
  zedless,
  ...
}: let
  zedlessPkg = zedless.packages.${pkgs.stdenv.hostPlatform.system}.zedless.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        ./patches/zedless/0001-generate-licenses.patch
      ];
  });
in {
  home-manager.users.tlv = {pkgs, ...}: {
    programs.zed-editor = {
      enable = true;
      package = zedlessPkg;
      extensions = [
        "html"
        "nix"
        "terraform"
      ];
      extraPackages = with pkgs; [
        nixd
        nixfmt
        package-version-server
        tailwindcss-language-server
        vscode-json-languageserver
        vtsls
      ];
      userSettings = {
        auto_update = false;
        buffer_font_size = 16;
        collaboration_panel = {
          button = false;
        };
        cursor_blink = false;
        git = {
          inline_blame = {
            enabled = false;
          };
        };
        gutter = {
          line_numbers = false;
        };
        languages = {
          JavaScript = {
            code_actions_on_format = {
              "source.fixAll.eslint" = true;
              "source.organizeImports" = true;
            };
          };
          Nix = {
            language_servers = [
              "!nil"
              "nixd"
            ];
          };
          TSX = {
            code_actions_on_format = {
              "source.fixAll.eslint" = true;
              "source.organizeImports" = true;
            };
          };
          TypeScript = {
            code_actions_on_format = {
              "source.fixAll.eslint" = true;
              "source.organizeImports" = true;
            };
          };
        };
        tab_size = 2;
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        vim_mode = true;
      };
    };
  };
}
