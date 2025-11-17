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
    nix-ai-tools.inputs.nixpkgs.follows = "nixpkgs";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-famly-fetch.url = "github:tlvince/nixpkgs/add-famly-fetch";
    nixpkgs-immich-kiosk.url = "github:tlvince/nixpkgs/kiosk-module";
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
    nix-ai-tools,
    nixpkgs,
    nixpkgs-famly-fetch,
    nixpkgs-immich-kiosk,
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
          zed-editor-fhs
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
          # TODO: Upstream nixos/immich-kiosk module
          # Issue URL: https://github.com/tlvince/nixos-config/issues/365
          # https://nixpkgs-tracker.ocfox.me/?pr=461579
          # labels: module:immich-kiosk, host:cm3588
          "${nixpkgs-immich-kiosk}/nixos/modules/services/web-apps/immich-kiosk.nix"
          ./hosts/cm3588.nix
          agenix.nixosModules.default
          disko.nixosModules.disko
        ];
      };
      framework = nixpkgs.lib.nixosSystem {
        specialArgs =
          inputs
          // {
            # TODO: Remove nix-ai-tools when codex-acp is in nixpkgs
            # Issue URL: https://github.com/tlvince/nixos-config/issues/384
            # https://github.com/NixOS/nixpkgs/pull/459454
            # labels: host:framework
            pkgs-ai = nix-ai-tools.packages."x86_64-linux";
            # TODO: Remove nixpkgs-famly-fetch when famly-fetch is upstreamed
            # Issue URL: https://github.com/tlvince/nixos-config/issues/383
            # https://github.com/NixOS/nixpkgs/pull/452904
            # labels: host:framework
            pkgs-famly-fetch = import nixpkgs-famly-fetch {
              system = "x86_64-linux";
            };
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
    };
  };
}
