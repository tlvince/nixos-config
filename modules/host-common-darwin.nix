{ ... }:
{
  nix.gc = {
    automatic = true;
    interval = [
      {
        Hour = 0;
        Minute = 0;
        Weekday = 1;
      }
    ];
    options = "--delete-older-than 30d";
  };
}
