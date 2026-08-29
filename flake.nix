{
  description = "@tlvince's NixOS config";

  inputs = {
    agent-sandbox.url = "github:archie-judd/agent-sandbox.nix";
    agent-sandbox.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
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
    # TODO: Drop dsh pin when PR is merged upstream
    # Issue URL: https://github.com/tlvince/nixos-config/issues/512
    # See: https://github.com/NixOS/nixpkgs/pull/554081
    # labels: host:nea, module:dsh
    nixpkgs-dsh.url = "github:Dietr1ch/nixpkgs/e33d86db2c8acafda91cb825576dd90db166ec7d";
    # TODO: Drop fastflowlm pin when PR is merged upstream
    # Issue URL: https://github.com/tlvince/nixos-config/issues/468
    # See: https://github.com/NixOS/nixpkgs/pull/513841
    # labels: host:framework
    nixpkgs-flm.url = "github:JohnMolotov/nixpkgs/db67e0576aa590228a55deacae8abdb9254f4580";
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
      agent-sandbox,
      agenix,
      disko,
      darwin,
      ghostwriter,
      home-manager,
      jail-nix,
      llm-agents,
      lanzaboote,
      nixpkgs,
      nixpkgs-dsh,
      nixpkgs-flm,
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
      pkgsFlm = import nixpkgs-flm {
        inherit system;
        config.allowUnfree = true;
      };
      pkgsDsh = import nixpkgs-dsh {
        system = "aarch64-linux";
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
            inherit pkgsFlm;
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
            inherit keys pkgsDsh;
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
