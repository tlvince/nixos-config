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
    ../modules/host-common-nixos.nix
    ../modules/host-common.nix
    ../modules/tmux.nix
  ];
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets."wireguard-loot".file = "${secretsPath}/wireguard-loot.age";
  age.secrets."wireguard-loot-framework-psk".file = "${secretsPath}/wireguard-loot-framework-psk.age";
  age.secrets."wireguard-loot-mobile-psk".file = "${secretsPath}/wireguard-loot-mobile-psk.age";
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "boot.panic_on_fail"
      "panic=1"
    ];
    loader = {
      efi.efiSysMountPoint = "/boot/efi";
      grub = {
        configurationLimit = 5;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
    };
    tmp.cleanOnBoot = true;
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
    device = "/dev/disk/by-uuid/8590cc2d-fd77-46e2-a99c-4d31710d4e1a";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/7DEE-CB18";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  networking = {
    enableIPv6 = false;
    hostName = "loot";
    nftables.enable = true;
    firewall = {
      allowedUDPPorts = [
        51820 # WireGuard
      ];
      filterForward = true;
      logRefusedConnections = false;
    };
    nameservers = [
      "45.90.28.0#${secrets.nextdns.loot}.dns.nextdns.io"
      "45.90.30.0#${secrets.nextdns.loot}.dns.nextdns.io"
    ];
    nat = {
      enable = true;
      externalInterface = "en*";
      internalInterfaces = [ "wg0" ];
    };
    useDHCP = false;
    wireguard = {
      useNetworkd = true;
      interfaces.wg0 = {
        ips = [ "10.12.5.1/32" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets."wireguard-loot".path;
        peers = [
          {
            allowedIPs = [ "10.12.5.2/32" ];
            presharedKeyFile = config.age.secrets."wireguard-loot-mobile-psk".path;
            publicKey = "WLSHRzYecQPqI26Zd2wo6WzAqqhIpkEmSB85C9GbvyY=";
          }
          {
            allowedIPs = [ "10.12.5.3/32" ];
            presharedKeyFile = config.age.secrets."wireguard-loot-framework-psk".path;
            publicKey = "gRXRNKC8GzJWzd3GNxxfHJsxjeG2/F8h9RJDXuXL+g0=";
          }
        ];
      };
    };
  };
  nixpkgs = {
    hostPlatform = "x86_64-linux";
  };
  programs.tmux = {
    extraConfig = ''
      set-option -g pane-active-border-style fg="#61afef"
      set-option -g status-style fg="#282c34",bg="#61afef"
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
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.resolved = {
    enable = true;
    settings.Resolve.DNSOverTLS = "true";
  };
  system.stateVersion = "26.11";
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
      dhcpV4Config.UseDNS = false;
    };
    networks."40-wg0" = {
      linkConfig.RequiredForOnline = false;
      networkConfig = {
        IPv4Forwarding = true;
      };
    };
  };
  systemd.services.tune2fs-root = {
    description = "Enable periodic ext4 filesystem checks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.e2fsprogs}/sbin/tune2fs -c -1 -i 1m ${config.fileSystems."/".device}";
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
  zramSwap.enable = true;
}
