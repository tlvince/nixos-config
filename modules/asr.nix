{
  ghostwriter,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    ghostwriter.packages.${pkgs.system}.asr
  ];

  hardware.uinput.enable = true;

  users.users.tlv.extraGroups = [
    "uinput"
  ];
}
