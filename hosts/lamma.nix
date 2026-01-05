{
  ...
}:
{
  documentation.enable = false;

  networking = {
    applicationFirewall = {
      allowSigned = true;
      allowSignedApp = true;
      enable = true;
      enableStealthMode = true;
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
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.Siri" = {
          "UAProfileCheckingStatus" = 0;
          "siriEnabled" = 0;
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

      dock.autohide = true;

      finder = {
        AppleShowAllExtensions = true;
        NewWindowTarget = "Home";
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      screencapture.location = "~/Pictures/screenshots";
      trackpad.Clicking = true;
    };
    primaryUser = "tlv";
    stateVersion = 6;
  };

  time.timeZone = "Europe/London";
  users.users.tlv.home = "/Users/tlv";
}
