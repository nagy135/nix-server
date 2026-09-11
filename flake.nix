{
  description = "NixOS server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Update T3 Code and Codex independently of the base system.
    t3code-nixpkgs.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    home-manager,
    hermes-agent,
    nixpkgs,
    t3code-nixpkgs,
    nixos-hardware,
    nvf,
    ...
  }: let
    formatterSystems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
    mkHost = {
      system,
      hostName,
      hermesDomain,
      hardwareModules,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit hermesDomain nvf;
          t3code = t3code-nixpkgs.legacyPackages.${system}.t3code;
          codex = t3code-nixpkgs.legacyPackages.${system}.codex;
        };
        modules =
          hardwareModules
          ++ [
            home-manager.nixosModules.home-manager
            hermes-agent.nixosModules.default
            ./configuration.nix
            {
              networking.hostName = hostName;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.infiniter = import ./home.nix;
              };
            }
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
        hermesDomain = "pi.infiniter.tech";
        hardwareModules = [
          nixos-hardware.nixosModules.raspberry-pi-5
          ./hardware-configuration-nixpi.nix
          ./nixpi.nix
        ];
      };

      hetzner = mkHost {
        system = "x86_64-linux";
        hostName = "hetzner";
        hermesDomain = "agent.infiniter.tech";
        hardwareModules = [./hardware-configuration-hetzner.nix];
      };
    };
  };
}
