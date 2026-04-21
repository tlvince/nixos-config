{
  description = "@tlvince's NixOS config";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    # TODO: Drop fastflowlm overlay
    # Issue URL: https://github.com/tlvince/nixos-config/issues/468
    # See: https://github.com/NixOS/nixpkgs/pull/494907
    # labels: host:framework
    nixpkgs-amdgpu.url = "github:Aleksanaa/nixpkgs/d8805ed18bfb7ed81cd7f64ae8a31b22ede0d8f5";
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
      nixpkgs-amdgpu,
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
      pkgsAmdgpu = import nixpkgs-amdgpu {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            fastflowlm = prev.fastflowlm.overrideAttrs (_: {
              version = "0.9.39";
              src = prev.fetchFromGitHub {
                owner = "FastFlowLM";
                repo = "FastFlowLM";
                tag = "v0.9.39";
                fetchSubmodules = true;
                hash = "sha256-HrPk7BrqyLnyt8Y/qgCZ1Eyic7w2KPiJLUI23tx8GFc=";
              };
            });
          })
        ];
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
            inherit pkgsAmdgpu;
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
      };
    };
}
