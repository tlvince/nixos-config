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

  boot.blacklistedKernelModules = ["hid_sensor_hub"];
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="GB"
    options snd_hda_intel power_save=1
  '';
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    configurationLimit = 5;
    pkiBundle = "/etc/secureboot";
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
    chromium
    diff-so-fancy
    ectool.packages."${pkgs.system}".ectool
    efm-langserver
    exiftool
    fd
    foot
    fzf
    gcc
    gh
    git
    gnome-text-editor
    gnome.gnome-calculator
    gnome.gnome-calendar
    gnome.gnome-clocks
    gnome.gnome-contacts
    gnome.nautilus
    gnomeExtensions.appindicator
    gnomeExtensions.light-style
    gnomeExtensions.night-theme-switcher
    gnumake
    gnupg
    htop
    jq
    kdiskmark
    libreoffice
    libva-utils
    loupe
    mpv
    neovim
    nodejs_20
    pass-wayland
    pinentry-gnome
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

  # Early KMS unnecessarily slows boot
  hardware.amdgpu.loadInInitrd = false;

  hardware.enableAllFirmware = true;
  hardware.pulseaudio.enable = false;
  hardware.sensor.iio.enable = false;
  hardware.wirelessRegulatoryDatabase = true;

  i18n.defaultLocale = "en_GB.UTF-8";
  networking.hostName = "framework";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    randomizedDelaySec = "1 hour";
  };
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
      auth       optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
      account    include                     login
      password   required                    pam_deny.so
      session    include                     login
      session    optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
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

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # https://github.com/NixOS/nixpkgs/blob/59e6ccce3ef1dff677840fa5bb71b79ea686ee12/nixos/modules/services/x11/desktop-managers/gnome.nix
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
    #gnome.nixos-background-info
    gnome.gnome-backgrounds
    gnome-tour
    gnome-user-docs
    orca
  ];

  # services.gnome.core-utilities
  programs.evince.enable = true;
  programs.file-roller.enable = true;
  programs.geary.enable = true;
  programs.gnome-disks.enable = true;
  programs.seahorse.enable = true;
  services.gnome.sushi.enable = true;

  services.resolved.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  '';

  system.stateVersion = "23.05";

  time.timeZone = "Europe/London";

  users.users.tlv = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
}
