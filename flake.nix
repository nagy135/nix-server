{
  description = "NixOS server configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Update T3 Code, Codex, and Claude Code independently of the base system.
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
      modules,
    }: let
      toolPkgs = import t3code-nixpkgs {
        inherit system;
        config.allowUnfreePredicate = package: nixpkgs.lib.getName package == "claude-code";
      };
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit hermesDomain nvf;
          inherit (toolPkgs) t3code codex claude-code;
        };
        modules =
          modules
          ++ [
            home-manager.nixosModules.home-manager
            hermes-agent.nixosModules.default
            ./modules/users.nix
            ./modules/services/hermes.nix
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
      nixzero = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [./hosts/nixzero];
      };

      nixpi = mkHost {
        system = "aarch64-linux";
        hostName = "nixpi";
        hermesDomain = "pi.infiniter.tech";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-5
          ./hosts/nixpi
        ];
      };

      hetzner = mkHost {
        system = "x86_64-linux";
        hostName = "hetzner";
        hermesDomain = "agent.infiniter.tech";
        modules = [./hosts/hetzner];
      };
    };
  };
}
