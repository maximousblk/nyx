# Centralized agenix-rekey configuration with multi-machine support
{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  # Pubkeys must be strings with no trailing newline for AGENIX_REKEY_PRIMARY_IDENTITY matching
  masterPubkeys = {
    zenbook = lib.removeSuffix "\n" (builtins.readFile (inputs.self.outPath + "/.secrets/master_zenbook.pub"));
    victus = lib.removeSuffix "\n" (builtins.readFile (inputs.self.outPath + "/.secrets/master_victus.pub"));
  };

  # Hosts with secrets that need path materialization
  hostsWithSecrets = [ "pyre" ];
in
{
  imports = [ inputs.agenix-rekey.flakeModule ];

  flake.secretsConfig = {
    masterIdentities = [
      {
        identity = "/home/ashwin_y/.ssh/id_ed25519";
        pubkey = masterPubkeys.zenbook;
      }
      {
        identity = "/home/maximousblk/.ssh/id_ed25519";
        pubkey = masterPubkeys.victus;
      }
    ];
    extraEncryptionPubkeys = [ inputs.ssh-keys-maximousblk ];
  };

  flake.masterPubkeys = masterPubkeys;

  perSystem =
    { config, pkgs, ... }:
    let
      # Script to force rekeyed secret paths into the nix store.
      # Required after `agenix rekey` for `nix flake check --no-build` to work.
      materialise = pkgs.writeShellScriptBin "materialise-secrets-to-nix-store" ''
        echo "Materializing rekeyed secret paths into the nix store..."
        ${lib.concatMapStringsSep "\n" (host: ''
          nix eval .#nixosConfigurations.${host}.config.age.secrets --apply 'secrets: builtins.mapAttrs (n: v: v.file) secrets' --json >/dev/null
        '') hostsWithSecrets}
        echo "Done."
      '';

      generate = pkgs.writeShellScriptBin "generate" ''
        ${config.agenix-rekey.package}/bin/agenix generate -a
      '';

      rekey = pkgs.writeShellScriptBin "rekey" ''
        ${config.agenix-rekey.package}/bin/agenix rekey -a && ${materialise}/bin/materialise-secrets-to-nix-store
      '';
    in
    {
      devShells.rekey = pkgs.mkShellNoCC {
        nativeBuildInputs = [
          config.agenix-rekey.package
          generate
          rekey
          materialise
          pkgs.rage
        ];

        env.AGENIX_REKEY_ADD_TO_GIT = "always";

        shellHook = ''
          # Set identity at shell runtime based on hostname
          case "$(hostname)" in
            zenbook) export AGENIX_REKEY_PRIMARY_IDENTITY=${pkgs.lib.escapeShellArg masterPubkeys.zenbook} ;;
            victus)  export AGENIX_REKEY_PRIMARY_IDENTITY=${pkgs.lib.escapeShellArg masterPubkeys.victus} ;;
            *)       echo "Unknown host: $(hostname), AGENIX_REKEY_PRIMARY_IDENTITY not set" ;;
          esac
          export AGENIX_REKEY_PRIMARY_IDENTITY_ONLY=true
        '';
      };
    };
}
