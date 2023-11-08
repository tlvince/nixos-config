{ config, pkgs, ... }:

{
  home.username = "tlv";
  home.homeDirectory = "/home/tlv";

  programs.git = {
    enable = true;
    userName = "Tom Vincent";
    userEmail = "git@tlvince.com";
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
        initial-window-mode = "fullscreen";
      };
      cursor = {
        style = "beam";
        blink = "yes";
        beam-thickness = 1;
      };
    };
  };

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
}
