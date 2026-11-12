{
  config,
  modulesPath,
  pkgs,
  keys,
  secrets,
  secretsPath,
  ...
}:
{
  imports = [
    # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ../modules/acme.nix
    ../modules/caltrack.nix
    ../modules/cpuload.nix
    ../modules/deepseek-harness.nix
    ../modules/host-common-nixos.nix
    ../modules/host-common.nix
    ../modules/tmux.nix
    ../modules/minuspod.nix
    ../modules/nginx.nix
  ];
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets."wireguard-nea".file = "${secretsPath}/wireguard-nea.age";
  age.secrets."wireguard-nea-mobile-psk".file = "${secretsPath}/wireguard-nea-mobile-psk.age";
  age.secrets."wireguard-nea-framework-psk".file = "${secretsPath}/wireguard-nea-framework-psk.age";
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "usbhid"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "boot.panic_on_fail"
      "panic=1"
    ];
    loader = {
      systemd-boot = {
        bootCounting.enable = true;
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
    xz
    zsh
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
      allowedUDPPorts = [
        51820 # WireGuard
      ];
      interfaces.wg0.allowedTCPPorts = [
        443 # nginx
      ];
      interfaces.wg0.allowedUDPPorts = [
        53 # dnsmasq
      ];
      logRefusedConnections = false;
    };
    nameservers = [
      "2a07:a8c0::#${secrets.nextdns.nea}.dns.nextdns.io"
      "2a07:a8c1::#${secrets.nextdns.nea}.dns.nextdns.io"
      "45.90.28.0#${secrets.nextdns.nea}.dns.nextdns.io"
      "45.90.30.0#${secrets.nextdns.nea}.dns.nextdns.io"
    ];
    useDHCP = false;
    wireguard = {
      useNetworkd = true;
      interfaces.wg0 = {
        ips = [ "10.12.3.1/32" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets."wireguard-nea".path;
        peers = [
          {
            allowedIPs = [ "10.12.3.2/32" ];
            presharedKeyFile = config.age.secrets."wireguard-nea-mobile-psk".path;
            publicKey = "5PKxnLmOs2ZHDWAsULapVF5tYNCWemOcVSt1+irocDo=";
          }
          {
            allowedIPs = [ "10.12.3.3/32" ];
            presharedKeyFile = config.age.secrets."wireguard-nea-framework-psk".path;
            publicKey = "oQfdwYibhttuZ3KfLAmVPGQtZNiEHr/PufF4OLp3SA4=";
          }
        ];
      };
    };
  };
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;
      interface = "wg0";
      listen-address = [ "10.12.3.1" ];
      domain-needed = true;
      local = "/filo.uk/";
      no-hosts = true;
      no-resolv = true;
      host-record = [
        "caltrack.filo.uk,10.12.3.1"
        "dsh.filo.uk,10.12.3.1"
        "minuspod.filo.uk,10.12.3.1"
      ];
    };
  };
  nixpkgs = {
    hostPlatform = "aarch64-linux";
  };
  programs.tmux = {
    extraConfig = ''
      set-option -g pane-active-border-style fg="#c678dd"
      set-option -g status-style fg="#282c34",bg="#c678dd"
    '';
  };
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
  programs.zsh.interactiveShellInit = ''
    export ZSHZ_CMD=j
    source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh
  '';
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
  services.resolved = {
    enable = true;
    settings.Resolve.DNSOverTLS = "true";
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
    networks."40-wg0".linkConfig.RequiredForOnline = false;
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
      openssh.authorizedKeys.keys = [
        keys.tlv
      ];
    };
  };
}
