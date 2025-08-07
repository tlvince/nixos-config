{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nil
    nixd
    package-version-server
    tailwindcss-language-server
    vscode-json-languageserver
    vtsls
    zed-editor
  ];
}
