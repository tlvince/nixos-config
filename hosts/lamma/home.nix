{
  pkgs,
  ...
}:
{
  home.stateVersion = "23.05";
  manual = {
    html.enable = false;
    manpages.enable = false;
    json.enable = false;
  };
  programs = {
    ghostty = {
      enable = true;
      package = pkgs.ghostty-bin;
    };
    git = {
      enable = true;
      settings = {
        user = {
          email = "git@tlvince.com";
          name = "Tom Vincent";
        };
      };
    };
    htop.enable = true;
  };
}
