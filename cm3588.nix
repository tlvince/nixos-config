{
  config,
  lib,
  linux-rockchip-collabora,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")
    ./modules/librespot.nix
  ];
  boot = {
    kernelPackages = pkgs.linuxPackagesFor (
      pkgs.buildLinux {
        extraMeta.branch = "6.13";
        modDirVersion = "6.13.0-rc7";
        src = linux-rockchip-collabora;
        version = "6.13.0-rc7";
      }
    );
    loader = {
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 3;
      };
    };
    tmp.useTmpfs = true;
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
    tmux
    xz
    zsh
    zsh-z
    zstd
  ];
  environment.variables.EDITOR = "nvim";
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e7bc49e1-b617-41b7-89df-c1e18c832b16";
    fsType = "btrfs";
    options = ["noatime" "commit=600" "compress=zstd" "subvol=/root"];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e7bc49e1-b617-41b7-89df-c1e18c832b16";
    fsType = "btrfs";
    options = ["noatime" "commit=600" "compress=zstd" "subvol=/nix"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e7bc49e1-b617-41b7-89df-c1e18c832b16";
    fsType = "btrfs";
    options = ["noatime" "commit=600" "compress=zstd" "subvol=/home"];
  };
  fileSystems."/mnt/btrfs-root" = {
    device = "/dev/disk/by-uuid/e7bc49e1-b617-41b7-89df-c1e18c832b16";
    fsType = "btrfs";
    options = ["noatime" "commit=600" "compress=zstd"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/14f6f35f-157c-4b47-803a-1d4dcfdd5328";
    fsType = "ext4";
  };
  fileSystems."/var/log" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=300M"];
  };
  services.journald.extraConfig = ''
    SystemMaxUse=300M
    Storage=volatile
  '';
  hardware.enableAllFirmware = true;
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
      DHCP = "yes";
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
