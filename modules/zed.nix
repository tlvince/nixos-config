{
  pkgs,
  zedless,
  ...
}: let
  # TODO: Drop Zedless patch
  # Issue URL: https://github.com/tlvince/nixos-config/issues/412
  # See: https://github.com/zedless-editor/zedless/pull/81
  # labels: module:zed
  zedlessPkg = zedless.packages.${pkgs.stdenv.hostPlatform.system}.zedless.overrideAttrs (old: let
    prevPostPatch = old.postPatch or "";
  in {
    postPatch =
      prevPostPatch
      + pkgs.lib.optionalString (prevPostPatch != "") "\n"
      + ''
        # The generate-licenses script wants a specific version of cargo-about eventhough
        # newer versions work just as well.
        substituteInPlace script/generate-licenses \
          --replace-fail '$CARGO_ABOUT_VERSION' '${pkgs.cargo-about.version}'
      '';
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
  };
}
