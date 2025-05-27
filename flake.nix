{
  description = "@tlvince's NixOS config";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    ectool.inputs.nixpkgs.follows = "nixpkgs";
    ectool.url = "github:tlvince/ectool.nix";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "git+https://github.com/nix-community/home-manager?shallow=1&ref=master";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    secrets.flake = false;
    secrets.url = "github:tlvince/nixos-config-secrets";
    tmux-colours-onedark.flake = false;
    tmux-colours-onedark.url = "github:tlvince/tmux-colours-onedark";
  };

  outputs = {
    agenix,
    disko,
    ectool,
    home-manager,
    lanzaboote,
    nixpkgs,
    secrets,
    self,
    tmux-colours-onedark,
    ...
  } @ inputs: let
    keys = import ./keys.nix;
  in {
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
      pkgs.mkShellNoCC {
        packages = with pkgs; [
          alejandra
        ];
      };
    devShells.x86_64-linux.nodejs = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
      pkgs.mkShellNoCC {
        packages = with pkgs; [
          azure-cli
          eslint_d
          nodePackages."@astrojs/language-server"
          nodePackages.bash-language-server
          nodePackages.typescript-language-server
          nodejs_22
          mongodb-tools
          mongosh
          terraform
          terraform-ls
        ];
      };
    nixosConfigurations = {
      cm3588 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit keys;
          secrets = import inputs.secrets;
          secretsPath = inputs.secrets.outPath;
        };

        modules = [
          ./cm3588.nix
          agenix.nixosModules.default
          disko.nixosModules.disko
        ];
      };
      framework = nixpkgs.lib.nixosSystem {
        specialArgs =
          inputs
          // {
            secretsPath = inputs.secrets.outPath;
          };
        modules = [
          ./configuration.nix
          agenix.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = inputs;
            home-manager.useGlobalPkgs = true;
            home-manager.users.tlv = import ./home.nix;
          }
          lanzaboote.nixosModules.lanzaboote
        ];
      };
      kernel = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          (
            {
              pkgs,
              lib,
              config,
              ...
            }: {
              boot = {
                kernelPackages = pkgs.linuxPackages_latest;
                kernelPatches = [
                  {
                    name = "mfd: cros_ec: Separate charge-control probing from USB-PD";
                    patch = pkgs.fetchpatch {
                      url = "https://lore.kernel.org/lkml/20250521-cros-ec-mfd-chctl-probe-v1-1-6ebfe3a6efa7@weissschuh.net/raw";
                      sha256 = "sha256-8nBcr7mFdUE40yHA1twDVbGKJ8tvAW+YRP23szUIhxk=";
                    };
                  }
                ];
                loader.grub.device = "/dev/disk/by-id/wwn-0x500001234567890a";
              };

              fileSystems."/" = {
                device = "/";
                fsType = "btrfs";
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

              nixpkgs.config.allowUnfree = true;
              nixpkgs.hostPlatform = "x86_64-linux";

              system.stateVersion = "25.11";
            }
          )
        ];
      };
    };
  };
}
