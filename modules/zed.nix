{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nil
    package-version-server
    tailwindcss-language-server
    vscode-json-languageserver
    vtsls
    zed-editor
  ];
}
