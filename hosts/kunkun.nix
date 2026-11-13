{
  config,
  modulesPath,
  pkgs,
  keys,
  secretsPath,
  ...
}:
{
  imports = [
    # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../modules/cpuload.nix
    ../modules/cycled.nix
    ../modules/host-common-nixos.nix
    ../modules/host-common.nix
    ../modules/nginx.nix
    ../modules/redditd.nix
    ../modules/tmux.nix
  ];
  age.secrets."wireguard-kunkun".file = "${secretsPath}/wireguard-kunkun.age";
  age.secrets."wireguard-kunkun-cm3588-psk".file = "${secretsPath}/wireguard-kunkun-cm3588-psk.age";
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
    hosts = {
      "127.0.0.1" = [
        "home-assistant.filo.uk"
      ];
    };
    enableIPv6 = false;
    hostName = "kunkun";
    firewall = {
      allowedUDPPorts = [
        51820 # WireGuard
      ];
      logRefusedConnections = false;
    };
    useDHCP = false;
    wireguard = {
      useNetworkd = true;
      interfaces.wg0 = {
        ips = [ "10.12.4.1/32" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets."wireguard-kunkun".path;
        peers = [
          {
            allowedIPs = [ "10.12.4.2/32" ];
            presharedKeyFile = config.age.secrets."wireguard-kunkun-cm3588-psk".path;
            publicKey = "8CHC810mutffX4b3bAAltRa14r+m7cnDPAZ3Xf8bvXQ=";
          }
        ];
      };
    };
  };
  nixpkgs = {
    hostPlatform = "aarch64-linux";
  };
  programs.tmux = {
    extraConfig = ''
      set-option -g pane-active-border-style fg="#e5c07b"
      set-option -g status-style fg="#282c34",bg="#e5c07b"
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
  services.nginx = {
    streamConfig = ''
      map $ssl_preread_server_name $sni_backend {
        home-assistant.filo.uk 10.12.4.2:443;
        default 127.0.0.1:1;
      }
      server {
        listen 0.0.0.0:443;
        ssl_preread on;
        proxy_pass $sni_backend;
      }
    '';
    defaultListenAddresses = [ "127.0.0.1" ];
    defaultHTTPListenPort = 9;
    defaultSSLListenPort = 9442;
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
      openssh.authorizedKeys.keys = [ keys.tlv ];
    };
  };
}
