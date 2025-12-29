{ ... }:
{
  home-manager.users.tlv =
    { pkgs, zedless, ... }:
    {
      programs.zed-editor = {
        enable = true;
        package = zedless.packages.${pkgs.stdenv.hostPlatform.system}.zedless;
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
          buffer_font_size = 16;
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
          vim_mode = true;
        };
      };

      # Use the Home Manager wrapper
      xdg.dataFile."applications/cooking.schizo.Zedless.desktop".text =
        pkgs.lib.replaceStrings
          [
            "TryExec=zedless"
            "Exec=zedless %U"
            "Exec=zedless --new %U"
          ]
          [
            "TryExec=zeditor"
            "Exec=zeditor %U"
            "Exec=zeditor --new %U"
          ]
          (
            builtins.readFile "${
              zedless.packages.${pkgs.stdenv.hostPlatform.system}.zedless
            }/share/applications/cooking.schizo.Zedless.desktop"
          );
    };
}
