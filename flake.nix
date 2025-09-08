{
  description = "@tlvince's NixOS config";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    secrets.flake = false;
    secrets.url = "github:tlvince/nixos-config-secrets";
    tmux-colours-onedark.flake = false;
    tmux-colours-onedark.url = "github:tlvince/tmux-colours-onedark";
  };

  outputs = {
    agenix,
    disko,
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
          ./hosts/cm3588.nix
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
          ./hosts/framework.nix
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
      kunkun = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit keys;
          secrets = import inputs.secrets;
          secretsPath = inputs.secrets.outPath;
        };
        modules = [
          ./hosts/kunkun.nix
          agenix.nixosModules.default
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
                    name = "drm/amd/display: Enable urgent latency adjustment on DCN35";
                    patch = pkgs.fetchpatch {
                      url = "https://github.com/torvalds/linux/commit/756c85e4d0ddc497b4ad5b1f41ad54e838e06188.patch";
                      sha256 = "sha256-bOF1ec72KO3bRRqAt3LWYwjEHCWB/rNMQ38UZH2qYNc=";
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
