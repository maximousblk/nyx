# Centralized agenix-rekey configuration with multi-machine support
{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  readPubkey = path: lib.trim (builtins.readFile (inputs.self + "/.secrets" + path));

  masterIdentities = {
    zenbook = {
      pubkey = readPubkey "/master_zenbook.pub";
      identity = "/home/ashwin_y/.ssh/id_ed25519";
    };
    victus = {
      pubkey = readPubkey "/master_victus.pub";
      identity = "/home/maximousblk/.ssh/id_ed25519";
    };
  };

  secretsConfig = {
    masterIdentities = lib.attrValues masterIdentities;
    extraEncryptionPubkeys = [ inputs.ssh-keys-maximousblk ];
  };

  agenixEnv = ''
    case "$(hostname)" in
      ${lib.concatStringsSep "\n    " (
        lib.mapAttrsToList (name: id: "${name}) export AGENIX_REKEY_PRIMARY_IDENTITY=${lib.escapeShellArg id.pubkey} ;;") masterIdentities
      )}
      *) echo "Unknown host: $(hostname), AGENIX_REKEY_PRIMARY_IDENTITY not set" >&2 ;;
    esac
    export AGENIX_REKEY_PRIMARY_IDENTITY_ONLY=true
    export AGENIX_REKEY_ADD_TO_GIT=always
  '';
in
{
  imports = [ inputs.agenix-rekey.flakeModule ];

  flake.secretsConfig = secretsConfig;

  perSystem =
    { config, pkgs, ... }:
    let
      hasSecrets = _: cfg: lib.hasAttr "age" cfg.config && lib.hasAttr "rekey" cfg.config.age;
      hostsWithSecrets = lib.attrNames (lib.filterAttrs hasSecrets inputs.self.nixosConfigurations);
    in
    {
      # Force rekeyed secret paths into the nix store per host.
      # Required after `agenix rekey` for `nix flake check --no-build` to work
      # with storageMode = "local".
      apps.secrets-materialise = {
        type = "app";
        meta.description = "Materialise rekeyed secret paths into the nix store";
        program = "${pkgs.writeShellScript "secrets-materialise" ''
          echo "Materializing rekeyed secret paths into the nix store..."
          ${lib.concatMapStringsSep "\n" (host: ''
            nix eval .#nixosConfigurations.${host}.config.age.secrets \
              --apply 'secrets: builtins.mapAttrs (n: v: v.file) secrets' \
              --json >/dev/null
          '') hostsWithSecrets}
          echo "Done."
        ''}";
      };
      apps.secrets-generate = {
        type = "app";
        meta.description = "Generate agenix secrets for all hosts";
        program = "${pkgs.writeShellScript "secrets-generate" ''
          ${agenixEnv}
          exec ${config.agenix-rekey.package}/bin/agenix generate -a "$@"
        ''}";
      };
      apps.secrets-rekey = {
        type = "app";
        meta.description = "Rekey agenix secrets for all hosts and materialise store paths";
        program = "${pkgs.writeShellScript "secrets-rekey" ''
          ${agenixEnv}
          ${config.agenix-rekey.package}/bin/agenix rekey -a "$@" \
            && exec ${config.apps.secrets-materialise.program}
        ''}";
      };
    };
}
