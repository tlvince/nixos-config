{
  ...
}:
{
  imports = [
    ../modules/host-common.nix
    ../modules/brave.nix
    ../modules/neovim.nix
  ];

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

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.overlays = [
    (final: prev: {
      # TODO: Remove mactop overlay
      # Build fails as of 2.0.5, see:
      # https://github.com/NixOS/nixpkgs/issues/483467
      # https://github.com/NixOS/nixpkgs/pull/477686
      # labels: host:lamma
      mactop = prev.mactop.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    defaults = {

      CustomUserPreferences = {
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
          allowIdentifierForAdvertising = false;
        };
        "com.apple.Siri" = {
          "UAProfileCheckingStatus" = 0;
          "siriEnabled" = 0;
        };
        "com.apple.assistant.support" = {
          "Search Queries Data Sharing Status" = 2;
          "Siri Data Sharing Opt-In Status" = 2;
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
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    primaryUser = "tlv";
    stateVersion = 6;
  };

  users.users.tlv.home = "/Users/tlv";
}
