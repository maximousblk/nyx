{
  inputs = {
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

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
      inputs.flake-compat.follows = "flake-compat";
      inputs.utils.follows = "flake-utils";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nix-systems.follows = "systems";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    stylix.url = "github:danth/stylix";

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";

  };

  outputs = (
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {

        imports = [
          inputs.treefmt-nix.flakeModule

          ./hosts/parts.nix
          ./homes/parts.nix
        ];

        systems = [ "x86_64-linux" ];

        perSystem = (
          { pkgs, system, ... }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;

              overlays = [ inputs.nur.overlays.default ];
            };

            _module.args.pkgx = import ./pkgx { inherit pkgs; };
            _module.args.modx = import ./modx;

            _module.args.homeManagerModules = [
              inputs.stylix.homeModules.stylix
              inputs.sops-nix.homeManagerModules.sops
              inputs.vicinae.homeManagerModules.default
              inputs.nix-index-database.homeModules.nix-index
              inputs.impermanence.homeManagerModules.impermanence
            ];
            _module.args.nixosModules = [
              inputs.disko.nixosModules.disko
              inputs.sops-nix.nixosModules.sops
              inputs.stylix.nixosModules.stylix
              inputs.quadlet-nix.nixosModules.quadlet
              inputs.home-manager.nixosModules.home-manager
              inputs.impermanence.nixosModules.impermanence
              inputs.nixos-facter-modules.nixosModules.facter
              inputs.nix-index-database.nixosModules.nix-index
            ];

            checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;

            treefmt.programs.nixfmt = {
              enable = true;
              strict = true;
              width = 160;
            };
          }
        );
      }
    )
  );
}
