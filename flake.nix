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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
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

    nixarr = {
      url = "github:rasmus-kirk/nixarr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nur.follows = "nur";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    files.url = "github:mightyiam/files";

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ssh-keys-maximousblk = {
      url = "https://github.com/maximousblk.keys";
      flake = false;
    };
  };

  outputs = (
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      {

        imports = [
          inputs.treefmt-nix.flakeModule

          ./secrets.nix
          ./topology.nix
          ./files.nix

          ./hosts/parts.nix
          ./homes/parts.nix
        ];

        systems = [ "x86_64-linux" ];

        perSystem = (
          {
            pkgs,
            system,
            config,
            ...
          }:
          let
            pkgx = import ./pkgx { inherit pkgs; };
            modx = import ./modx;
          in
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;

              overlays = [
                inputs.nur.overlays.default
                inputs.nix-topology.overlays.default
                inputs.fenix.overlays.default
              ];
            };

            _module.args.pkgx = pkgx;
            _module.args.modx = modx;

            _module.args.homeManagerModules = [
              inputs.stylix.homeModules.stylix
              inputs.vicinae.homeManagerModules.default
              inputs.nix-index-database.homeModules.nix-index
              inputs.impermanence.homeManagerModules.impermanence
            ];
            _module.args.nixosModules = [
              inputs.disko.nixosModules.disko
              inputs.stylix.nixosModules.stylix
              inputs.quadlet-nix.nixosModules.quadlet
              inputs.nixarr.nixosModules.default
              inputs.home-manager.nixosModules.home-manager
              inputs.impermanence.nixosModules.impermanence
              inputs.nixos-facter-modules.nixosModules.facter
              inputs.nix-index-database.nixosModules.nix-index
              inputs.nix-topology.nixosModules.default
            ];

            checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;

            treefmt.programs.nixfmt = {
              enable = true;
              strict = true;
              width = 160;
            };

            packages.deploy-rs = inputs.deploy-rs.packages.${system}.default;
            packages.home-manager = inputs.home-manager.packages.${system}.default;
            packages.agenix = config.agenix-rekey.package;
          }
        );
      }
    )
  );
}
