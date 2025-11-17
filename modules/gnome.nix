{pkgs, ...}: {
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # https://github.com/NixOS/nixpkgs/blob/93da65ede655736068698f9da6470ca9d1484861/nixos/modules/services/desktop-managers/gnome.nix
  services.gnome = {
    core-developer-tools.enable = false;
    core-os-services.enable = true;
    core-shell.enable = true;
    core-apps.enable = false;
    games.enable = false;

    # services.gnome.gnome-shell
    gnome-browser-connector.enable = false;
    gnome-initial-setup.enable = false;
    gnome-remote-desktop.enable = false;
    gnome-user-share.enable = false;
    rygel.enable = false;
    sushi.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    evince
    geary
    gnome-backgrounds
    gnome-shell-extensions
    gnome-tour
    gnome-user-docs
    orca
  ];

  # GNOME-specific system packages
  environment.systemPackages = with pkgs; [
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-contacts
    gnome-text-editor
    gnomeExtensions.appindicator
    gnomeExtensions.light-style
    gnomeExtensions.night-theme-switcher
    loupe
    nautilus
    papers
    pinentry-gnome3
  ];

  programs.evolution = {
    enable = true;
    plugins = with pkgs; [
      evolution-ews
    ];
  };

  home-manager.users.tlv = {
    config,
    lib,
    pkgs,
    ...
  }: {
    dconf.settings = {
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file://${config.xdg.dataHome}/backgrounds/ChromeOSWind-1.png";
        picture-uri-dark = "file://${config.xdg.dataHome}/backgrounds/ChromeOSWind-2.png";
        primary-color = "#3465a4";
        secondary-color = "#000000";
      };

      "org/gnome/desktop/input-sources" = {
        sources = [
          (lib.hm.gvariant.mkTuple ["xkb" "us+altgr-intl"])
        ];
        xkb-options = [
          "caps:escape"
        ];
      };

      "org/gnome/desktop/interface" = {
        document-font-name = "Sans 11";
        enable-animations = false;
        enable-hot-corners = false;
        font-antialiasing = "grayscale";
        font-hinting = "none";
        font-name = "Sans 11";
        monospace-font-name = "Monospace 12.5";
        show-battery-percentage = true;
      };

      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = false;
      };

      "org/gnome/desktop/session" = {
        idle-delay = 120;
      };

      "org/gnome/desktop/sound" = {
        event-sounds = false;
        theme-name = "__custom";
      };

      "org/gnome/desktop/wm/preferences" = {
        titlebar-font = "Sans Bold 11";
      };

      "org/gnome/mutter" = {
        experimental-features = [
          "variable-refresh-rate"
        ];
      };

      "org/gnome/settings-daemon/plugins/power" = {
        idle-dim = true;
        power-button-action = "suspend";
        power-saver-profile-on-low-battery = true;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-timeout = 900;
        sleep-inactive-battery-type = "suspend";
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "light-style@gnome-shell-extensions.gcampax.github.com"
          "nightthemeswitcher@romainvigier.fr"
        ];
        favorite-apps = [
          "firefox.desktop"
          "foot.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Evolution.desktop"
          "org.gnome.Calendar.desktop"
        ];
      };
    };

    home.file = {
      "${config.xdg.dataHome}/backgrounds/ChromeOSWind-1.png".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/refs/heads/main/Dynamic_Wallpapers/ChromeOSWind/ChromeOSWind-1.png";
        hash = "sha256-lT6dvLymLtlJ+xFFyX7k1aV0lTBceZXRJSeCQvJqA3o=";
      };
      "${config.xdg.dataHome}/backgrounds/ChromeOSWind-2.png".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/refs/heads/main/Dynamic_Wallpapers/ChromeOSWind/ChromeOSWind-2.png";
        hash = "sha256-jB0T07ro1QtJ6fYcu/IKHZB8ESNbqwpVHtA9nr8alUg=";
      };
    };

    services.gpg-agent = lib.mkIf config.services.gpg-agent.enable {
      pinentry.package = pkgs.pinentry-gnome3;
    };

    # Disable XWayland
    xdg.configFile."systemd/user/org.gnome.Shell@wayland.service.d/override.conf".text = ''
      [Service]
      ExecStart=
      ExecStart=${pkgs.gnome-shell}/bin/gnome-shell --no-x11
    '';

    # services.gnome.core-services pulls in the freedesktop sound theme:
    # https://github.com/NixOS/nixpkgs/blob/93da65ede655736068698f9da6470ca9d1484861/nixos/modules/services/desktop-managers/gnome.nix#L355-L359
    # Power sounds are played despite org/gnome/desktop/sound event-sounds=false
    # Workaround by disabling them in a custom theme:
    # https://specifications.freedesktop.org/sound-theme/latest/sound_lookup.html
    xdg.dataFile."sounds/__custom/index.theme".text = ''
      [Sound Theme]
      Name=__custom
      Directories=stereo

      [stereo]
      OutputProfile=stereo
    '';
    xdg.dataFile."sounds/__custom/stereo/power-plug.disabled".text = "";
    xdg.dataFile."sounds/__custom/stereo/power-unplug.disabled".text = "";
  };
}
