{
  ghostwriter,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    ghostwriter.packages.${pkgs.stdenv.hostPlatform.system}.asr
  ];

  hardware.uinput.enable = true;

  users.users.tlv.extraGroups = [
    "uinput"
  ];
}
