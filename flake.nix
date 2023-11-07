{
  description = "@tlvince's NixOS config";

  inputs = {
    disko.url = "github:nix-community/disko";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs: {
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
	  home-manager.nixosModules.home-manager
	  {
	    home-manager.useGlobalPkgs = true;
	    home-manager.users.tlv = import ./home.nix;
	  }
        ];
      };
    };
  };
}
