{ ... }:
{
  home-manager.users.tlv =
    { pkgs, zed, ... }:
    {
      programs.zed-editor = {
        enable = true;
        package = zed.packages.${pkgs.stdenv.hostPlatform.system}.default;
        extensions = [
          "html"
          "nix"
          "terraform"
        ];
        extraPackages = with pkgs; [
          codex-acp
          nixd
          nixfmt
          package-version-server
          tailwindcss-language-server
          vscode-json-languageserver
          vtsls
        ];
        userSettings = {
          agent_servers = {
            codex = {
              command = "${pkgs.codex-acp.outPath}/bin/codex-acp";
            };
          };
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
