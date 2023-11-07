{ config, pkgs, ... }:

{
  home.username = "tlv";
  home.homeDirectory = "/home/tlv";

  programs.git = {
    enable = false;
    userName = "Tom Vincent";
    userEmail = "git@tlvince.com";
  };

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
}
