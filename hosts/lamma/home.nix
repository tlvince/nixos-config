{
  pkgs,
  ...
}:
{
  home = {
    sessionVariables = {
      ZSHZ_CMD = "j";
    };
    stateVersion = "25.11";
  };
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
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    zsh = {
      enable = true;
      initContent = ''
        source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh
      '';
    };

  };
}
