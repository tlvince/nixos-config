{
  config,
  pkgs,
  lib,
  apple-fonts,
  ectool,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-configuration.nix
  ];

  boot = {
    blacklistedKernelModules = ["hid_sensor_hub"];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
    '';
    initrd.systemd.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelPatches = [
      {
        name = "drm/amdgpu/vcn: identify unified queue in sw init";
        patch = pkgs.fetchpatch {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/patch/?id=23fddba4039916caa6a96052732044ddcf514886";
          sha256 = "sha256-SdRJbXGNaS17QPDhfkdrCHV8XsQU1oVRUQL9w0/Xgic=";
        };
      }
      {
        name = "drm/amdgpu/vcn: not pause dpg for unified queue";
        patch = pkgs.fetchpatch {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/superm1/linux.git/patch/?id=3941fd6be7cf050225db4b699757969f8950e2ce";
          sha256 = "sha256-EoM2leGLKm5PPQs1ik1yuJMV3V7MEegbSD6hmrDsNF0=";
        };
      }
    ];
    kernel.sysctl = {
      # enable REISUB: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
      "kernel.sysrq" = 1 + 16 + 32 + 64 + 128;
    };
    lanzaboote = {
      enable = true;
      configurationLimit = 3;
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
    brave
    brightnessctl
    btrbk
    chromium
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
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome.gnome-clocks
    gnome.gnome-contacts
    nautilus
    gnomeExtensions.appindicator
    gnomeExtensions.light-style
    gnomeExtensions.night-theme-switcher
    gnumake
    gnupg
    htop
    jpegoptim
    jq
    libreoffice
    libva-utils
    loupe
    mpv
    neovim
    nodejs_20
    optipng
    pass-wayland
    papers
    pinentry-gnome3
    prettierd
    powerstat
    powertop
    pure-prompt
    python3
    sbctl
    signal-desktop
    tmux
    tree
    wl-clipboard
    yt-dlp
    zsh
    zsh-z
  ];

  environment.variables = {
    EDITOR = "nvim";
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
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
        enable = true;
        autohint = false;
        style = "slight";
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

  hardware.enableAllFirmware = true;
  hardware.pulseaudio.enable = false;
  hardware.sensor.iio.enable = false;

  i18n.defaultLocale = "en_GB.UTF-8";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # Expo
      8081
    ];
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
    substituters = [
      "https://tlvince-nixos-config.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "tlvince-nixos-config.cachix.org-1:PYVWI+uNlq7mSJxFSPDkkCEtaeQeF4WvjtQKa53ZOyM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Workaround for gdm
  # See: https://github.com/NixOS/nixpkgs/issues/171136
  # See: https://github.com/NixOS/nixpkgs/pull/171140
  security.pam.services.login.fprintAuth = false;
  security.pam.services.gdm-fingerprint = lib.mkIf (config.services.fprintd.enable) {
    text = ''
      auth       required                    pam_shells.so
      auth       requisite                   pam_nologin.so
      auth       requisite                   pam_faillock.so      preauth
      auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
      auth       optional                    pam_permit.so
      auth       required                    pam_env.so
      auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
      auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
      account    include                     login
      password   required                    pam_deny.so
      session    include                     login
      session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
    '';
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

  # https://github.com/NixOS/nixpkgs/blob/9acffcc32acba3f2bd523d007e5e0239deb8e612/nixos/modules/services/x11/desktop-managers/gnome.nix
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
    gnome.gnome-backgrounds
    gnome.gnome-shell-extensions
    gnome-tour
    gnome-user-docs
    orca
  ];

  # services.gnome.core-utilities
  programs.evince.enable = false;
  programs.file-roller.enable = true;
  programs.geary.enable = false;
  programs.gnome-disks.enable = true;
  programs.seahorse.enable = true;
  services.gnome.sushi.enable = true;

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
    # Power switching, power saver handled by GNOME when low capacity (20%)
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
  '';

  system.stateVersion = "23.05";

  time.timeZone = "Europe/London";

  users.users.tlv = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
}
