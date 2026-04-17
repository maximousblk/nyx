{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age.rekey = {
    # Obtained via: ssh-keyscan -t ed25519 cairn
    hostPubkey = builtins.readFile (inputs.self + "/.secrets/cairn/host.pub");

    inherit (inputs.self.secretsConfig) masterIdentities extraEncryptionPubkeys;

    storageMode = "local";
    localStorageDir = inputs.self + "/.secrets/cairn/rekeyed";
    generatedSecretsDir = inputs.self + "/.secrets/cairn/generated";
    secretsDir = inputs.self + "/.secrets/cairn/manual";
  };
}
