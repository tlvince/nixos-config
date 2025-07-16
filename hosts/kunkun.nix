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
    (modulesPath + "/profiles/perlless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../modules/acme.nix
    ../modules/cpuload.nix
    ../modules/cycled.nix
    ../modules/nginx.nix
  ];
  boot = {
    initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid"];
    initrd.systemd.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        configurationLimit = 5;
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    diffutils
    findutils
    gitMinimal
    gnugrep
    gnupatch
    gnused
    gnutar
    gzip
    htop
    less
    neovim
    rsync
    tree
    tmux
    xz
    zsh
    zsh-z
    zstd
  ];

  environment.variables.EDITOR = "nvim";

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "btrfs";
    options = ["compress=zstd" "noatime"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-boot";
    fsType = "vfat";
  };

  hardware.enableRedistributableFirmware = true;

  i18n.defaultLocale = "en_GB.UTF-8";
  networking = {
    hosts = {
      "127.0.0.1" = [
        "home-assistant.filo.uk"
        "test.filo.uk"
      ];
    };
    enableIPv6 = false;
    hostName = "kunkun";
    firewall = {
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
  security.sudo.extraRules = [
    {
      users = ["tlv"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
  services.btrfs.autoScrub = {
    enable = true;
    interval = "*-*-01 06:00"; # 0600 monthly
    fileSystems = [
      "/"
    ];
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
      AllowUsers = [
        "cm3588"
        "tlv"
      ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.fstrim.enable = true;
  services.nginx = {
    upstreams.home-assistant.servers."127.0.0.1:8080" = {};

    virtualHosts."home-assistant.filo.uk" = {
      forceSSL = true;
      useACMEHost = "filo.uk";

      locations."/" = {
        proxyPass = "https://home-assistant";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_ssl_name $host;
          proxy_ssl_server_name on;
        '';
      };
    };
  };

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
    networks.wired = {
      name = "en*";
      DHCP = "yes";
    };
  };
  time.timeZone = "Europe/London";
  users = {
    defaultUserShell = pkgs.zsh;
    groups.cm3588 = {};
    users.tlv = {
      extraGroups = [
        "wheel"
      ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [keys.tlv];
    };
    users.cm3588 = {
      group = config.users.groups.cm3588.name;
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        ''command="/bin/false",restrict,port-forwarding ${keys.cm3588}''
      ];
    };
  };
}
