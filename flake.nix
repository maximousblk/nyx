{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        # "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      pkgxFor = forAllSystems (system: (import ./pkgx) { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      nixosConfigurations.victus = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgx = pkgxFor."x86_64-linux";
        };
        modules = [ ./hosts/victus/configuration.nix ];
      };

      homeConfigurations.umbra = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };

        extraSpecialArgs = {
          inherit inputs;
          pkgx = pkgxFor."x86_64-linux";
        };

        modules = [ ./homes/umbra/home.nix ];
      };

      deploy.nodes.victus = {
        hostname = "victus";
        sshUser = "maximousblk";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.victus;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
