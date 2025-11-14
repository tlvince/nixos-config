{
  pkgs,
  pkgs-ai,
  ...
}: {
  environment.systemPackages =
    (with pkgs; [
      nil
      package-version-server
      tailwindcss-language-server
      vscode-json-languageserver
      vtsls
      zed-editor
    ])
    ++ [pkgs-ai.codex-acp];
}
