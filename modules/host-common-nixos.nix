{ pkgs, ... }:
{
  boot.kernelParams = [
    # Disable UAS for WD Elements to prevent controller resets
    "usb-storage.quirks=1058:2621:u"
    # Disable UAS on Seagate One Touch
    "usb-storage.quirks=0bc2:ab64:u"
  ];

  hardware.enableRedistributableFirmware = true;

  i18n.defaultLocale = "en_GB.UTF-8";

  programs.nano.enable = false;
  programs.zsh.enable = true;

  services.fstrim.enable = true;

  users.defaultUserShell = pkgs.zsh;
}
