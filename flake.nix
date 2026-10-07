{
  description = "@tlvince's NixOS config";

  inputs = {
    agent-sandbox.url = "github:archie-judd/agent-sandbox.nix";
    agent-sandbox.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    cm3588-pwm-fan.flake = false;
    cm3588-pwm-fan.url = "github:tlvince/cm3588-pwm-fan";
    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    ghostwriter.url = "github:tlvince/ghostwriter";
    ghostwriter.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    linux-rknpu-rk3588.inputs.nixpkgs.follows = "nixpkgs";
    linux-rknpu-rk3588.url = "github:heliosrun/linux-rknpu-rk3588";
    nixpkgs-upstream.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:tlvince/nixpkgs/nixos-config";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    secrets.flake = false;
    secrets.url = "github:tlvince/nixos-config-secrets";
    tmux-colours-onedark.flake = false;
    tmux-colours-onedark.url = "github:tlvince/tmux-colours-onedark";
  };

  outputs =
    {
      agent-sandbox,
      agenix,
      cm3588-pwm-fan,
      disko,
      darwin,
      ghostwriter,
      home-manager,
      jail-nix,
      llm-agents,
      lanzaboote,
      linux-rknpu-rk3588,
      nixpkgs,
      nvf,
      secrets,
      self,
      tmux-colours-onedark,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      keys = import ./keys.nix;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
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
              home-manager.extraSpecialArgs = {
                inherit agent-sandbox;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tlv = ./hosts/lamma/home.nix;
            }
          ];
        };
      };
      devShells.${system}.nodejs = pkgs.mkShellNoCC {
        packages = with pkgs; [
          azure-cli
          eslint_d
          astro-language-server
          bash-language-server
          typescript-language-server
          nodejs_24
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
            inherit cm3588-pwm-fan keys;
            secrets = import inputs.secrets;
            secretsPath = inputs.secrets.outPath;
          };

          modules = [
            ./hosts/cm3588.nix
            agenix.nixosModules.default
            disko.nixosModules.disko
            linux-rknpu-rk3588.nixosModules.rknpu
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
              home-manager.useUserPackages = true;
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
        nea = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit keys;
            secrets = import inputs.secrets;
            secretsPath = inputs.secrets.outPath;
          };
          modules = [
            ./hosts/nea.nix
            agenix.nixosModules.default
          ];
        };
      };
    };
}
