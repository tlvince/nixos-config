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
    # TODO: Drop dsh patch when PR is merged upstream
    # Issue URL: https://github.com/tlvince/nixos-config/issues/512
    # See: https://github.com/NixOS/nixpkgs/pull/554081
    # labels: host:nea, module:dsh
    nixpkgs-patch-dsh.flake = false;
    nixpkgs-patch-dsh.url = "https://github.com/NixOS/nixpkgs/pull/554081.diff?full_index=1";
    # TODO: Drop fastflowlm patch when PR is merged upstream
    # Issue URL: https://github.com/tlvince/nixos-config/issues/468
    # See: https://github.com/NixOS/nixpkgs/pull/513841
    # labels: host:framework
    nixpkgs-patch-flm.flake = false;
    nixpkgs-patch-flm.url = "https://github.com/NixOS/nixpkgs/pull/513841.diff?full_index=1";
    # TODO: Drop minuspod patch when PR is merged upstream
    # Issue URL: https://github.com/tlvince/nixos-config/issues/535
    # See: https://github.com/NixOS/nixpkgs/pull/568344
    # labels: host:nea, module:minuspod
    nixpkgs-patch-minuspod.flake = false;
    nixpkgs-patch-minuspod.url = "https://github.com/NixOS/nixpkgs/pull/568344.diff?full_index=1";
    # TODO: Drop soloist patch when PR merged upstream
    # Issue URL: https://github.com/tlvince/nixos-config/issues/533
    # See: https://github.com/NixOS/nixpkgs/pull/565860
    # labels: host:cm3588
    nixpkgs-patch-soloist.flake = false;
    nixpkgs-patch-soloist.url = "https://github.com/NixOS/nixpkgs/pull/565860.diff?full_index=1";
    # TODO: Drop nodejs patch when PR is merged upstream
    # (nodejs-slim-26.10.0 fails to build from source on aarch64-linux
    # with V8 memcopy.h CHAR_BIT error, builder exit 2, which breaks
    # minuspod-frontend)
    # Issue URL: https://github.com/tlvince/nixos-config/issues/534
    # See: https://github.com/NixOS/nixpkgs/pull/570428
    # labels: host:nea, module:minuspod
    nixpkgs-patch-nodejs.flake = false;
    nixpkgs-patch-nodejs.url = "https://github.com/NixOS/nixpkgs/pull/570428.diff?full_index=1";
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
      cm3588-pwm-fan,
      disko,
      darwin,
      ghostwriter,
      home-manager,
      jail-nix,
      llm-agents,
      lanzaboote,
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
      pkgsForPatching = import nixpkgs { system = "x86_64-linux"; };
      patchedSrc = pkgsForPatching.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          inputs.nixpkgs-patch-dsh
          inputs.nixpkgs-patch-flm
          inputs.nixpkgs-patch-minuspod
          inputs.nixpkgs-patch-nodejs
          inputs.nixpkgs-patch-soloist
        ];
      };
      # Re-import the patched flake to get its lib
      patchedPkgs = (import "${patchedSrc}/flake.nix").outputs {
        self = {
          outPath = patchedSrc;
        };
      };
      pkgs = import patchedSrc {
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
      formatter.aarch64-darwin = patchedPkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
      nixosConfigurations = {
        cm3588 = patchedPkgs.lib.nixosSystem {
          specialArgs = {
            inherit cm3588-pwm-fan keys;
            secrets = import inputs.secrets;
            secretsPath = inputs.secrets.outPath;
          };

          modules = [
            ./hosts/cm3588.nix
            agenix.nixosModules.default
            disko.nixosModules.disko
          ];
        };
        framework = patchedPkgs.lib.nixosSystem {
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
        kunkun = patchedPkgs.lib.nixosSystem {
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
        nea = patchedPkgs.lib.nixosSystem {
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
