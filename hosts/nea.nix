{
  modulesPath,
  pkgs,
  keys,
  ...
}:
{
  imports = [
    # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/perlless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../modules/host-common.nix
    ../modules/host-common-nixos.nix
    ../modules/cpuload.nix
  ];
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "usbhid"
    ];
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
    rsync
    tree
    tmux
    xz
    zsh
    zsh-z
    zstd
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
    ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-boot";
    fsType = "vfat";
  };

  networking = {
    enableIPv6 = false;
    hostName = "nea";
    firewall = {
      logRefusedConnections = false;
    };
    useDHCP = false;
  };
  nixpkgs.hostPlatform = "aarch64-linux";

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  security.sudo.extraRules = [
    {
      users = [ "tlv" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
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
        "tlv"
      ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
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
  users = {
    users.tlv = {
      extraGroups = [
        "wheel"
      ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ keys.tlv ];
    };
  };
}
