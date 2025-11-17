{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../modules/famly-fetch.nix
    ../modules/firefox.nix
    ../modules/gnome.nix
    ../modules/smartd.nix
    ../modules/zed.nix
  ];

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  boot = {
    blacklistedKernelModules = ["hid_sensor_hub"];
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
    # TODO: Restore userspace charge limiter
    # Issue URL: https://github.com/tlvince/nixos-config/issues/309
    # See https://patchwork.kernel.org/project/chrome-platform/patch/20250521-cros-ec-mfd-chctl-probe-v1-1-6ebfe3a6efa7@weissschuh.net/
    # See https://github.com/torvalds/linux/commits/master/drivers/mfd/cros_ec_dev.c
    # See https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/70
    # labels: host:framework, unreleased
    kernelPackages = pkgs.linuxPackages_latest;

    # TODO: Fix screen flickering
    # Issue URL: https://github.com/tlvince/nixos-config/issues/320
    # Grey flickers, particularly in Firefox
    #
    # Attempts:
    # [x] disable variable refresh rate
    # [x] reseating display cable
    # [x] increase GPU memory to 1GB, 8GB
    # [x] disable PSR-SU
    # [x] linux-firmware git
    # [x] 6.16-rc6
    # [x] increase DCN35 SR latency by 2us
    # [ ] disable memory stutter (dcdebugmask=0x2)
    #
    # See: https://community.frame.work/t/flickering-when-using-firefox-under-kde-wayland-on-ryzen-ai-300/69599
    # See: https://gitlab.freedesktop.org/drm/amd/-/issues/4451
    # See: https://gitlab.freedesktop.org/drm/amd/-/issues/4463
    # labels: host:framework
    kernelParams = [
      # https://docs.kernel.org/gpu/amdgpu/driver-core.html#c.DC_DEBUG_MASK
      "amdgpu.dcdebugmask=0x2"
    ];

    kernel.sysctl = {
      # enable REISUB: https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
      "kernel.sysrq" = 1 + 16 + 32 + 64 + 128;
    };
    lanzaboote = {
      enable = true;
      configurationLimit = 2;
      pkiBundle = "/var/lib/sbctl";
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkForce false;
    };
  };

  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "100M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  mountpoint = "/mnt/btrfs-root";
                  mountOptions = ["compress=zstd" "noatime"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                  };
                };
              };
            };
          };
        };
      };
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
    efm-langserver
    exiftool
    fd
    framework-tool
    foot
    fzf
    gcc
    gh
    git
    gnome-monitor-config
    gnumake
    gnupg
    htop
    imagemagick
    jpegoptim
    jq
    libreoffice
    libva-utils
    mpv
    neovim
    nodejs
    optipng
    pass-wayland
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
        # TODO: Remove Chromium Vulkan flags when upstreamed
        # Issue URL: https://github.com/tlvince/nixos-config/issues/308
        # Enables Touchpad gestures for navigation, VA-API, Vulkan (H.265/HEVC)
        # labels: host:framework
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
    packages = with pkgs; [
      dejavu_fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
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
        sansSerif = ["Adwaita Sans"];
        monospace = ["DejaVu Sans Mono"];
        emoji = ["Noto Color Emoji"];
      };
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

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  programs.adb.enable = true;

  programs.nano.enable = false;
  programs.zsh.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  services.btrbk.instances = {
    btrbk = {
      # TODO: btrbk timer disabled in favour of hourly & daily timers
      # Remove when upstreamed in NixOS or merged in with local btrbk module
      # labels: module:btrbk, host:framework
      # Issue URL: https://github.com/tlvince/nixos-config/issues/304
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
              "ssh://cm3588/mnt/ichbiah/snapshots/framework" = {
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
  services.hardware.bolt.enable = true;
  services.power-profiles-daemon.enable = true;
  services.printing.enable = false;
  services.resolved.enable = true;

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
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced", RUN+="${pkgs.systemd}/bin/systemd-run --user --machine tlv@ ${pkgs.gnome-monitor-config}/bin/gnome-monitor-config set --logical-monitor --monitor eDP-1 --primary --mode '2880x1920@60.001+vrr' --scale 2", RUN+="${pkgs.runtimeShell} -c '${pkgs.coreutils}/bin/echo 0 > /sys/class/leds/chromeos:white:power/brightness'"
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced", RUN+="${pkgs.systemd}/bin/systemd-run --user --machine tlv@ ${pkgs.gnome-monitor-config}/bin/gnome-monitor-config set --logical-monitor --monitor eDP-1 --primary --mode '2880x1920@120.000+vrr' --scale 2", RUN+="${pkgs.runtimeShell} -c '${pkgs.coreutils}/bin/echo 0 > /sys/class/leds/chromeos:white:power/brightness'"
  '';

  system.stateVersion = "23.05";

  time.timeZone = "Europe/London";

  users = {
    defaultUserShell = pkgs.zsh;
    users.tlv = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
    };
  };
}
