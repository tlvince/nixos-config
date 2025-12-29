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
  environment.systemPackages = with pkgs;
    [
      codex-acp
      nil
      package-version-server
      tailwindcss-language-server
      vscode-json-languageserver
      vtsls
    ]
    ++ [
      zedlessPkg
    ];
}
