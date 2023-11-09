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
        #initial-window-mode = "fullscreen";
      };
      cursor = {
        style = "beam";
        blink = "yes";
        beam-thickness = 1;
      };
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto";
      ytdl-format = "(bestvideo[vcodec^=av01][height<=?2160]/bestvideo[height<=?2160])+bestaudio/best";
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
