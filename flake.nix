{
  description = "NixOS server configurations";

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
    formatterSystems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
    mkHost = {
      system,
      hostName,
      hardwareModules,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit nvf;};
        modules =
          hardwareModules
          ++ [
            ./configuration.nix
            {networking.hostName = hostName;}
          ];
      };
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

    nixosConfigurations = {
      nixpi = mkHost {
        system = "aarch64-linux";
        hostName = "nixpi";
        hardwareModules = [
          nixos-hardware.nixosModules.raspberry-pi-5
          ./hardware-configuration-nixpi.nix
          ./nixpi.nix
        ];
      };

      hetzner = mkHost {
        system = "x86_64-linux";
        hostName = "hetzner";
        hardwareModules = [./hardware-configuration-hetzner.nix];
      };
    };
  };
}
