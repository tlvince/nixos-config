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
      # TODO: Remove mactop overlay once PR #477686 is merged and nixpkgs updated
      # Issue URL: https://github.com/tlvince/nixos-config/issues/451
      # Build fails as of 2.0.5, see:
      # https://github.com/NixOS/nixpkgs/issues/483467
      # https://github.com/NixOS/nixpkgs/pull/477686
      # labels: host:lamma
      mactop = prev.buildGoModule {
        pname = "mactop";
        version = "2.1.3";

        src = prev.fetchFromGitHub {
          owner = "metaspartan";
          repo = "mactop";
          tag = "v2.1.3";
          hash = "sha256-rWALbjy7s6X3hegcUxoR0XUXKFZGnWRWV5OeXtN3BjU=";
        };

        vendorHash = "sha256-TF66wg8nyAb/kZ80XLaD7H39EehZQ896DS6Ce3+P8Lk=";

        proxyVendor = true;

        ldflags = [
          "-s"
          "-w"
        ];

        doInstallCheck = true;
        doCheck = false;
        nativeInstallCheckInputs = [ prev.versionCheckHook ];

        versionCheckProgramArg = "--version";

        passthru.updateScript = prev.nix-update-script { };

        meta = {
          description = "Terminal-based monitoring tool 'top' designed to display real-time metrics for Apple Silicon chips";
          homepage = "https://github.com/metaspartan/mactop";
          changelog = "https://github.com/metaspartan/mactop/releases/tag/v2.1.3";
          license = prev.lib.licenses.mit;
          maintainers = with prev.lib.maintainers; [ natsukium ];
          mainProgram = "mactop";
          platforms = [ "aarch64-darwin" ];
        };
      };
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

      dock = {
        autohide = true;
        static-only = true;
        # Disable hot corners
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Home";
        QuitMenuItem = true;
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
