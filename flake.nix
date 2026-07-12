{
  description = "Raspberry Pi 5 Nextcloud server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixos-hardware,
    nvf,
    ...
  }: let
    formatterSystems = ["aarch64-darwin" "aarch64-linux"];
  in {
    formatter = nixpkgs.lib.genAttrs formatterSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.writeShellApplication {
          name = "nix-fmt";
          runtimeInputs = [pkgs.alejandra];
          text = "exec alejandra .";
        }
    );

    nixosConfigurations.raspberry-pi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {inherit nvf;};
      modules = [
        nixos-hardware.nixosModules.raspberry-pi-5
        ./configuration.nix
      ];
    };
  };
}
