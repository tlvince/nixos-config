{
  ...
}:
{

  networking = {
    applicationFirewall = {

      enable = true;
      enableStealthMode = true;
      allowSigned = true;
      allowSignedApp = true;
    };
    hostName = "lamma";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://tlvince-nixos-config.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "tlvince-nixos-config.cachix.org-1:PYVWI+uNlq7mSJxFSPDkkCEtaeQeF4WvjtQKa53ZOyM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = [
      "tlv"
    ];
  };
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
  };
  system = {
    defaults = {

      CustomUserPreferences = {
        "com.apple.Siri" = {
          "UAProfileCheckingStatus" = 0;
          "siriEnabled" = 0;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
      };

      NSGlobalDomain = {
        AppleInterfaceStyleSwitchesAutomatically = true;
        "com.apple.swipescrolldirection" = true;
      };

      WindowManager = {
        StandardHideDesktopIcons = true;
        StandardHideWidgets = true;
      };

      controlcenter.BatteryShowPercentage = true;
      trackpad.Clicking = true;

      dock.autohide = true;

      finder = {
        AppleShowAllExtensions = true;
        NewWindowTarget = "Home";
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      screencapture.location = "~/Pictures/screenshots";
    };
    primaryUser = "tlv";
  };
  time.timeZone = "Europe/London";
}
