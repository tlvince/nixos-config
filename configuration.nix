{ config, pkgs, lib, apple-fonts, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    brightnessctl
    foot
    git
    gnome-text-editor
    gnome.gnome-calculator
    gnome.gnome-calendar
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome.nautilus
    htop
    libva-utils
    mpv
    neovim
    powerstat
    powertop
    tree
    yt-dlp
    zsh
  ];

  fonts = {
    enableDefaultPackages = false;
    packages = [
      pkgs.noto-fonts-color-emoji
      apple-fonts.packages."${pkgs.system}".sf-mono
      apple-fonts.packages."${pkgs.system}".sf-pro
    ];

    fontconfig = {
      antialias = true;

      hinting = {
        enable = false;
        autohint = false;
        style = "none";
      };

      subpixel = {
        lcdfilter = "none";
        rgba = "none";
      };

      defaultFonts = {
        serif = [ "DejaVu Serif"];
        sansSerif = [ "SF Pro Text" ];
        monospace = [ "SF Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };

      localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <selectfont>
          <rejectfont>
            <pattern>
              <patelt name="family">
                <string>Cantarell</string>
              </patelt>
            </pattern>
          </rejectfont>
        </selectfont>
      </fontconfig>
      '';
    };
  };

  # Early KMS unnecessarily slows boot
  hardware.amdgpu.loadInInitrd = false;

  hardware.enableAllFirmware = true;
  hardware.pulseaudio.enable = false;
  hardware.sensor.iio.enable = false;

  i18n.defaultLocale = "en_GB.UTF-8";
  networking.hostName = "framework";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Workaround for gdm
  # See: https://github.com/NixOS/nixpkgs/issues/171136
  # See: https://github.com/NixOS/nixpkgs/pull/171140
  security.pam.services.login.fprintAuth = false;
  security.pam.services.gdm-fingerprint =
    lib.mkIf (config.services.fprintd.enable) {
      text = ''
        auth       required                    pam_shells.so
        auth       requisite                   pam_nologin.so
        auth       requisite                   pam_faillock.so      preauth
        auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
        auth       optional                    pam_permit.so
        auth       required                    pam_env.so
        auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
        auth       optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
        account    include                     login
        password   required                    pam_deny.so
        session    include                     login
        session    optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
      '';
    };

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # https://github.com/NixOS/nixpkgs/blob/59e6ccce3ef1dff677840fa5bb71b79ea686ee12/nixos/modules/services/x11/desktop-managers/gnome.nix
  services.gnome.core-developer-tools.enable = false;
  services.gnome.core-os-services.enable = true;
  services.gnome.core-shell.enable = true;
  services.gnome.core-utilities.enable = false;
  services.gnome.games.enable = false;
  services.printing.enable = false;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # services.gnome.core-shell
  services.gnome.gnome-browser-connector.enable = false;
  services.gnome.gnome-initial-setup.enable = false;
  services.gnome.gnome-remote-desktop.enable = false;
  services.gnome.gnome-user-share.enable = false;
  services.gnome.rygel.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    # services.gnome.core-shell
    #gnome.nixos-background-info
    gnome.gnome-backgrounds
    gnome-tour
    gnome-user-docs
    orca
  ];

  # services.gnome.core-utilities
  programs.evince.enable = true;
  programs.file-roller.enable = true;
  programs.geary.enable = true;
  programs.gnome-disks.enable = true;
  programs.seahorse.enable = true;
  services.gnome.sushi.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  system.stateVersion = "23.05";

  time.timeZone = "Europe/London";

  users.users.tlv = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
