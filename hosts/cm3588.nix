{
  config,
  lib,
  modulesPath,
  pkgs,
  keys,
  ...
}: {
  imports = [
    # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")

    ../modules/acme.nix
    ../modules/archive.nix
    ../modules/btrbk.nix
    ../modules/dmesgd.nix
    ../modules/dnsmasq.nix
    ../modules/home-assistant.nix
    ../modules/immich.nix
    ../modules/immich-kiosk.nix
    ../modules/mosquitto.nix
    ../modules/nginx.nix
    ../modules/postgres.nix
    ../modules/radicale.nix
    ../modules/redditd.nix
    ../modules/samba.nix
    ../modules/shairport-sync.nix
    ../modules/smartd.nix
    ../modules/tunnel.nix
    ../modules/zigbee2mqtt.nix
  ];
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 3;
      };
    };
  };
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Western_Digital_SN730_500GB_20461D801737";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                mountpoint = "/mnt/fowler";
                mountOptions = ["compress=zstd" "noatime"];
                extraArgs = ["-f"];
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

  environment.etc.crypttab.text = ''
    dijkstra UUID=e14d08e4-7123-4d86-bae0-b3de6f00454f /mnt/ichbiah/home/tlv/cryptsetup-keys.d/dijkstra.key noauto
    eich UUID=cb299988-72fa-42ae-91f2-593150f06c3f /mnt/ichbiah/home/tlv/cryptsetup-keys.d/eich.key noauto
    godel UUID=fda93065-2a13-4e26-a2b6-91df80d0ced0 /root/cryptsetup-keys.d/godel.key
    huffman UUID=e017c3f2-fa81-43e6-af9a-33f99abbc647 /root/cryptsetup-keys.d/huffman.key
  '';

  environment.systemPackages = with pkgs; [
    btrbk
    coreutils
    cryptsetup
    curl
    diffutils
    findutils
    git
    gnugrep
    gnupatch
    gnused
    gnutar
    gzip
    htop
    less
    neovim
    rsync
    smartmontools
    tree
    tmux
    xz
    zsh
    zsh-z
    zstd
  ];

  environment.variables.EDITOR = "nvim";

  fileSystems."/mnt/ichbiah/home" = {
    device = "/dev/mapper/godel";
    fsType = "btrfs";
    options = ["compress=zstd" "noatime" "subvol=/home"];
  };
  fileSystems."/mnt/ichbiah/snapshots" = {
    device = "/dev/mapper/godel";
    fsType = "btrfs";
    options = ["compress=zstd" "noatime" "subvol=/snapshots"];
  };
  fileSystems."/mnt/libraries/ichbiah" = {
    device = "/mnt/ichbiah/home/photos";
    depends = ["/mnt/ichbiah/home"];
    fsType = "none";
    options = ["bind" "ro" "nosuid" "nodev" "noexec"];
  };

  hardware.alsa.enable = true;
  hardware.enableRedistributableFirmware = true;

  i18n.defaultLocale = "en_GB.UTF-8";
  networking = {
    domain = "filo.uk";
    enableIPv6 = false;
    hostName = "cm3588";
    hosts = {
      "192.168.0.2" = [
        "cm3588"
        "cm3588.filo.uk"
        "home-assistant.filo.uk"
        "immich.filo.uk"
        "immich-kiosk.filo.uk"
        "radicale.filo.uk"
        "test.filo.uk"
      ];
    };
    firewall = {
      allowedTCPPorts = [
        53
        443
      ];
      allowedUDPPorts = [
        53
        67
      ];
      logRefusedConnections = false;
    };
    useDHCP = false;
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
    hostPlatform = "aarch64-linux";
  };
  programs.nano.enable = false;
  programs.zsh.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "*-*-01 06:00"; # 0600 monthly
    fileSystems = [
      "/"
      "/mnt/ichbiah/home"
    ];
  };
  systemd.timers.btrfs-scrub-mnt-ichbiah-home.timerConfig = {
    OnCalendar = lib.mkForce "*-*-01 06:30"; # 0630 monthly
  };
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    openFirewall = true;
    settings = {
      AllowGroups = [
        "btrbk"
        "wheel"
      ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.fstrim.enable = true;
  system.stateVersion = "25.05";
  system.tools = {
    nixos-build-vms.enable = false;
    nixos-enter.enable = false;
    nixos-generate-config.enable = false;
    nixos-install.enable = false;
    nixos-option.enable = false;
  };
  systemd.network = {
    enable = true;
    # Workaround router firmware bug that breaks 2.5Gbps ethernet
    links.wired = {
      matchConfig.Type = "ether";
      extraConfig = ''
        [EnergyEfficientEthernet]
        Enable=false
      '';
    };
    networks.wired = {
      name = "en*";
      address = ["192.168.0.2/24"];
      gateway = ["192.168.0.1"];
    };
  };
  time.timeZone = "Europe/London";
  tlvince.smartd.devices = [
    "/dev/nvme0"
    "/dev/nvme1"
    "/dev/nvme2"
  ];
  users = {
    defaultUserShell = pkgs.zsh;
    groups.nas = {};
    users.tlv = {
      extraGroups = [
        config.users.groups.nas.name
        "wheel"
      ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [keys.tlv];
    };
    users.zan = {
      extraGroups = [
        config.users.groups.nas.name
      ];
      isNormalUser = true;
    };
  };
  zramSwap.enable = true;
}
