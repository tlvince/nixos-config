{
  pkgs,
  zedless,
  ...
}: {
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
      zedless.packages.${pkgs.stdenv.hostPlatform.system}.zedless
    ];
}
