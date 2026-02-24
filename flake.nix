{
  description = "@tlvince's NixOS config";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    zed.inputs.nixpkgs.follows = "nixpkgs";
    zed.url = "github:zed-industries/zed";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    secrets.flake = false;
    secrets.url = "github:tlvince/nixos-config-secrets";
    tmux-colours-onedark.flake = false;
    tmux-colours-onedark.url = "github:tlvince/tmux-colours-onedark";
  };

  outputs =
    {
      agenix,
      disko,
      darwin,
      home-manager,
      jail-nix,
      lanzaboote,
      nixpkgs,
      nvf,
      secrets,
      self,
      tmux-colours-onedark,
      zed,
      ...
    }@inputs:
    let
      keys = import ./keys.nix;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      system = "x86_64-linux";
    in
    {
      darwinConfigurations = {
        lamma = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/lamma.nix
            nvf.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              home-manager.users.tlv = ./hosts/lamma/home.nix;
            }
          ];
        };
      };
      devShells.${system}.nodejs = pkgs.mkShellNoCC {
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
      formatter.${system} = pkgs.nixfmt-tree;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
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
          specialArgs = inputs // {
            secrets = import inputs.secrets;
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
            nvf.nixosModules.default
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
