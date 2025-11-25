{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    codex-acp
    nil
    package-version-server
    tailwindcss-language-server
    vscode-json-languageserver
    vtsls
    zed-editor
  ];
}
