{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")

    ./modules/shairport-sync.nix
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
                mountpoint = "/mnt/btrfs-root";
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
    smartmontools
    tree
    tmux
    xz
    zsh
    zsh-z
    zstd
  ];
  environment.variables.EDITOR = "nvim";
  hardware.enableRedistributableFirmware = true;
  i18n.defaultLocale = "en_GB.UTF-8";
  networking = {
    useDHCP = false;
    enableIPv6 = false;
    firewall.logRefusedConnections = false;
    hostName = "cm3588";
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
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      AllowGroups = ["wheel"];
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
      address = ["192.168.0.3/24"];
      gateway = ["192.168.0.1"];
      dns = ["192.168.0.2" "192.168.0.1" "1.1.1.1" "1.0.0.1"];
    };
  };
  time.timeZone = "Europe/London";
  users = {
    defaultUserShell = pkgs.zsh;
    users.tlv = {
      extraGroups = ["wheel"];
      isNormalUser = true;
      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKygwTvfwbmEgZXvOYCHX3pY1dNNPGxMn15HCktIemRF"];
      shell = pkgs.zsh;
    };
  };
  zramSwap.enable = true;
}
