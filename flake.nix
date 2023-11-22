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
    home-manager.url = "github:nix-community/home-manager";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, disko, ectool, home-manager, nixos-hardware, ... }@inputs: {
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.tlv = import ./home.nix;
          }
          nixos-hardware.nixosModules.framework-13-7040-amd
        ];
      };
    };
  };
}
