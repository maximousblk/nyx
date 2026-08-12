# Centralized agenix-rekey configuration with multi-machine support
{ config, inputs, ... }:
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

  masterPubkeys = lib.unique (lib.mapAttrsToList (_: id: id.pubkey) masterIdentities);

  githubPubkeys = lib.splitString "\n" (lib.trim (builtins.readFile inputs.ssh-keys-maximousblk));

  secretsConfig = {
    masterIdentities = lib.attrValues masterIdentities;
    extraEncryptionPubkeys = githubPubkeys;
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

  options.flake.secretFiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Age-encrypted secret files to add to the shared agenix-rekey rules.";
  };

  config = {
    flake.secretsConfig = secretsConfig;
    flake.agenixRules = lib.genAttrs config.flake.secretFiles (_: {
      publicKeys = masterPubkeys ++ githubPubkeys;
    });

    perSystem =
      { config, pkgs, ... }:
      let
        agenixRulesFile = pkgs.writeText "agenix-rules.nix" (pkgs.lib.generators.toPretty { } inputs.self.agenixRules);
        hasSecrets = _: cfg: lib.hasAttr "age" cfg.config && lib.hasAttr "rekey" cfg.config.age;
        hostsWithSecrets = lib.attrNames (lib.filterAttrs hasSecrets inputs.self.nixosConfigurations);
        expectedRekeyedPath =
          host: secret:
          let
            hostConfig = inputs.self.nixosConfigurations.${host}.config;
            pubkeyHash = builtins.hashString "sha256" hostConfig.age.rekey.hostPubkey;
            identHash = builtins.substring 0 32 (builtins.hashString "sha256" (pubkeyHash + builtins.hashFile "sha256" secret.rekeyFile));
          in
          hostConfig.age.rekey.localStorageDir + "/${identHash}-${secret.name}.age";
        checkedRekeyedPath =
          host: name: secret:
          let
            rekeyedPath = expectedRekeyedPath host secret;
          in
          assert lib.assertMsg (builtins.pathExists rekeyedPath) "Missing rekeyed secret for ${host}:${name}: ${rekeyedPath}";
          rekeyedPath;
        rekeyedSecretPaths = lib.concatMap (
          host:
          lib.mapAttrsToList (name: secret: checkedRekeyedPath host name secret) (
            lib.filterAttrs (_: secret: secret.rekeyFile != null && !secret.intermediary) inputs.self.nixosConfigurations.${host}.config.age.secrets
          )
        ) hostsWithSecrets;
      in
      {
        packages.agenyx = pkgs.writeShellScriptBin "agenyx" ''
          ${agenixEnv}
          exec ${config.agenix-rekey.package}/bin/agenix "$@"
        '';
        packages.agenix-rules = agenixRulesFile;

        checks.secrets = builtins.deepSeq rekeyedSecretPaths (pkgs.runCommand "secrets-check" { } "touch $out");

        # Explicitly materialise rekeyed secret paths for callers that need secret.file before a system build.
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
              && exec nix run .#secrets-materialise
          ''}";
        };
      };
  };
}
