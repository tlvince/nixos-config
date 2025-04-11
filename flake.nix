{
  description = "@tlvince's NixOS config";

  inputs = {
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";
    apple-fonts.url = "github:tlvince/apple-fonts.nix";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    ectool.inputs.nixpkgs.follows = "nixpkgs";
    ectool.url = "github:tlvince/ectool.nix";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "git+https://github.com/nix-community/home-manager?shallow=1&ref=master";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    tmux-colours-onedark.flake = false;
    tmux-colours-onedark.url = "github:tlvince/tmux-colours-onedark";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    ectool,
    home-manager,
    lanzaboote,
    tmux-colours-onedark,
    ...
  } @ inputs: {
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
    in pkgs.mkShellNoCC {
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
        modules = [
          ./cm3588.nix
          disko.nixosModules.disko
        ];
      };
      framework = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          ./configuration.nix
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
    };
  };
}
