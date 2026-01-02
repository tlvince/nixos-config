{
  pkgs,
  ...
}:
{
  home.stateVersion = "25.11";
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };
  programs = {
    ghostty = {
      enable = true;
      package = pkgs.ghostty-bin;
      settings = {
        font-size = 16;
        theme = "dark:Atom One Dark,light:Atom One Light";
      };
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
