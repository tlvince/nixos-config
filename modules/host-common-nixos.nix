{ pkgs, ... }:
{
  hardware.enableRedistributableFirmware = true;

  i18n.defaultLocale = "en_GB.UTF-8";

  programs.nano.enable = false;
  programs.zsh.enable = true;

  services.fstrim.enable = true;

  users.defaultUserShell = pkgs.zsh;
}
