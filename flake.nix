{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = inputs@{ self, nixpkgs, nixvim, home-manager, ... }: 
  let
    platform = "x86_64-linux";
    nixvimPkg = import ./nixvim { 
      inherit nixvim;
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${platform};
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nixvimPkg
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.infiniter = import ./home;
        }

      ];
    };
  };
}
