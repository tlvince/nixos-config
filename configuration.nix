{
  config,
  pkgs,
  lib,
  apple-fonts,
  ectool,
  ...
}: {
  imports = [
    ./disko-configuration.nix
  ];

  boot = {
    blacklistedKernelModules = ["hid_sensor_hub"];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
    '';
    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "thunderbolt"
        "usb_storage"
        "xhci_pci"
      ];
      systemd.enable = true;
    };
    kernelModules = [
      "kvm-amd"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      # enable REISUB: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
      "kernel.sysrq" = 1 + 16 + 32 + 64 + 128;
    };
    lanzaboote = {
      enable = true;
      configurationLimit = 2;
      pkiBundle = "/etc/secureboot";
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkForce false;
    };
  };

  environment.pathsToLink = [
    "/share/zsh"
  ];
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.en
    awscli2
    brightnessctl
    btrbk
    diff-so-fancy
    dig
    ectool.packages."${pkgs.system}".ectool
    efm-langserver
    evolution
    exiftool
    fd
    foot
    fzf
    gcc
    gh
    git
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-contacts
    gnome-monitor-config
    gnome-text-editor
    gnomeExtensions.appindicator
    gnomeExtensions.light-style
    gnomeExtensions.night-theme-switcher
    gnumake
    gnupg
    htop
    imagemagick
    jpegoptim
    jq
    libreoffice
    libva-utils
    loupe
    moreutils
    mpv
    nautilus
    neovim
    nodejs
    optipng
    papers
    pass-wayland
    pinentry-gnome3
    powerstat
    powertop
    prettierd
    pure-prompt
    python3
    rclone
    rquickshare
    sbctl
    signal-desktop
    tmux
    tree
    wl-clipboard
    yt-dlp
    zip
    zsh
    zsh-z
    (chromium.override {
      commandLineArgs = [
        # Touchpad gestures for navigation, VA-API, Vulkan (H.265/HEVC)
        "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
      ];
    })
  ];

  environment.variables = {
    EDITOR = "nvim";
    QT_QPA_PLATFORM = "wayland";
  };

  fonts = {
    enableDefaultPackages = false;
    packages = [
      pkgs.noto-fonts-color-emoji
      apple-fonts.packages."${pkgs.system}".sf-pro
    ];

    fontconfig = {
      antialias = true;

      hinting = {
        enable = false;
        autohint = false;
        style = "none";
      };

      subpixel = {
        lcdfilter = "none";
        rgba = "none";
      };

      defaultFonts = {
        serif = ["DejaVu Serif"];
        sansSerif = ["SF Pro Text"];
        monospace = ["DejaVu Sans Mono"];
        emoji = ["Noto Color Emoji"];
      };

      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <selectfont>
            <rejectfont>
              <pattern>
                <patelt name="family">
                  <string>Cantarell</string>
                </patelt>
              </pattern>
            </rejectfont>
          </selectfont>
        </fontconfig>
      '';
    };
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.sensor.iio.enable = false;

  i18n.defaultLocale = "en_GB.UTF-8";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # Expo
      8081
      # rquickshare
      44812
    ];
    # https://wiki.nixos.org/wiki/WireGuard#Setting_up_WireGuard_with_NetworkManager
    extraCommands = ''
      iptables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      iptables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    '';
    extraStopCommands = ''
      iptables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      iptables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
  };
  networking.hostName = "framework";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    randomizedDelaySec = "1 hour";
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
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  programs.firefox = {
    enable = true;
    policies = {
      AppAutoUpdate = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      CaptivePortal = false;
      DisableFeedbackCommands = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableProfileImport = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PasswordManagerEnabled = false;
      FirefoxHome = {
        Highlights = false;
        Locked = true;
        Pocket = false;
        Search = true;
        Snippets = false;
        SponsoredPocket = false;
        SponsoredTopSites = false;
        TopSites = true;
      };
      FirefoxSuggest = {
        ImproveSuggest = false;
        Locked = true;
        SponsoredSuggestions = false;
        WebSuggestions = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        FirefoxLabs = false;
        Locked = true;
        MoreFromMozilla = false;
        SkipOnboarding = true;
        UrlbarInterventions = false;
      };
    };
  };
  programs.nano.enable = false;
  programs.zsh.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  services.btrbk.instances = {
    btrbk = {
      # Timer disabled in favour of hourly & daily timers
      # TODO: upstream more configurables
      onCalendar = null;
      settings = {
        backend_remote = "btrfs-progs-sudo";
        lockfile = "/var/lib/btrbk/btrbk.lock";
        snapshot_create = "onchange";
        snapshot_dir = "snapshots";
        ssh_identity = "/var/lib/btrbk/.ssh/id_ed25519";
        ssh_user = "btrbk";
        timestamp_format = "long";

        archive_preserve = "30d *m";
        archive_preserve_min = "latest";
        snapshot_preserve = "24h 7d 0w 0m 0y";
        snapshot_preserve_min = "latest";
        target_preserve = "0h 14d 6w 4m 1y";
        target_preserve_min = "latest";

        volume = {
          "/mnt/btrfs-root" = {
            target = {
              "ssh://bpim5:6683/mnt/catmull/snapshots/${config.networking.hostName}" = {
                subvolume = {
                  "/" = {
                    snapshot_name = "root";
                  };
                  "/home" = {};
                };
              };
            };
          };
        };
      };
    };
  };

  systemd.services.btrbk-local = {
    description = "Take local Btrfs snapshots";
    unitConfig.Documentation = "man:btrbk(1)";
    path = ["/run/wrappers"] ++ config.services.btrbk.extraPackages;
    after = ["time-sync.target"];
    serviceConfig = {
      User = "btrbk";
      Group = "btrbk";
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk snapshot";
      Nice = config.services.btrbk.niceness;
      IOSchedulingClass = config.services.btrbk.ioSchedulingClass;
      StateDirectory = "btrbk";
    };
  };

  systemd.services.btrbk-remote = {
    description = "Takes local Btrfs snapshots and back up to given targets";
    unitConfig.Documentation = "man:btrbk(1)";
    path = ["/run/wrappers"] ++ config.services.btrbk.extraPackages;
    wants = ["network-online.target"];
    after = ["btrbk-local.service" "network-online.target" "time-sync.target"];
    serviceConfig = {
      User = "btrbk";
      Group = "btrbk";
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk run";
      Nice = config.services.btrbk.niceness;
      IOSchedulingClass = config.services.btrbk.ioSchedulingClass;
      StateDirectory = "btrbk";
    };
  };

  systemd.timers.btrbk-local = {
    description = "Timer to take Btrfs snapshots and maintain retention policies.";
    wantedBy = ["timers.target"];
    timerConfig = {
      AccuracySec = "10min";
      OnBootSec = "5min";
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "5min";
    };
  };

  systemd.timers.btrbk-remote = {
    description = "Timer to take Btrfs snapshots and maintain retention policies.";
    wantedBy = ["timers.target"];
    timerConfig = {
      AccuracySec = "10min";
      OnBootSec = "5min";
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "5min";
    };
  };

  services.fprintd.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # https://github.com/NixOS/nixpkgs/blob/d1f920fa88f38a50cab7ba62d77b7e1d5727222d/nixos/modules/services/x11/desktop-managers/gnome.nix
  services.gnome.core-developer-tools.enable = false;
  services.gnome.core-os-services.enable = true;
  services.gnome.core-shell.enable = true;
  services.gnome.core-utilities.enable = false;
  services.gnome.games.enable = false;
  services.hardware.bolt.enable = true;
  services.printing.enable = false;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.enable = true;
  services.xserver.excludePackages = [pkgs.xterm];

  # services.gnome.core-shell
  services.gnome.gnome-browser-connector.enable = false;
  services.gnome.gnome-initial-setup.enable = false;
  services.gnome.gnome-remote-desktop.enable = false;
  services.gnome.gnome-user-share.enable = false;
  services.gnome.rygel.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    # services.gnome.core-shell
    evince
    geary
    gnome-backgrounds
    gnome-shell-extensions
    gnome-tour
    gnome-user-docs
    orca
  ];

  services.resolved.enable = true;
  services.power-profiles-daemon.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.udev.extraRules = ''
    # PCI auto suspend
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    # USB auto suspend
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    # Power switching, power saver handled by GNOME/UPower when low capacity (20%)
    # https://github.com/NixOS/nixpkgs/blob/2e1715cf7cf3c1e79436d566962aeedaffbfb49d/nixos/modules/services/hardware/upower.nix#L88
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced", RUN+="${pkgs.systemd}/bin/systemd-run --user --machine tlv@ ${pkgs.gnome-monitor-config}/bin/gnome-monitor-config set --logical-monitor --monitor eDP-1 --primary --mode '2880x1920@60.001+vrr' --scale 2", RUN+="${ectool.packages."${pkgs.system}".ectool}/bin/ectool led power off"
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced", RUN+="${pkgs.systemd}/bin/systemd-run --user --machine tlv@ ${pkgs.gnome-monitor-config}/bin/gnome-monitor-config set --logical-monitor --monitor eDP-1 --primary --mode '2880x1920@120.000+vrr' --scale 2", RUN+="${ectool.packages."${pkgs.system}".ectool}/bin/ectool led power auto"
  '';

  system.stateVersion = "23.05";

  time.timeZone = "Europe/London";

  users = {
    defaultUserShell = pkgs.zsh;
    users.tlv = {
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}
