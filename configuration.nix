{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [
    foot
    gnome-text-editor
    gnome.gnome-calculator
    gnome.gnome-calendar
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome.nautilus
    htop
    neovim
    tree
    powertop
    libva-utils
    mpv
  ];

  hardware.enableRedistributableFirmware = true;

  i18n.defaultLocale = "en_GB.UTF-8";
  networking.hostName = "framework";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.fprintd.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
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
  services.pipewire.enable = true;

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

  programs.firefox.enable = true;

  system.stateVersion = "23.05";

  time.timeZone = "Europe/London";

  users.users.tlv = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
