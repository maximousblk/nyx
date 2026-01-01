# agenix-rekey configuration for pyre
{ inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age.rekey = {
    # Obtained via: ssh-keyscan -t ed25519 pyre.pony-clownfish.ts.net
    hostPubkey = builtins.readFile (inputs.self + "/.secrets/pyre/host.pub");

    # Use shared master identities from flake.secretsConfig
    inherit (inputs.self.secretsConfig) masterIdentities extraEncryptionPubkeys;

    storageMode = "local";
    localStorageDir = inputs.self + "/.secrets/pyre/rekeyed";
    generatedSecretsDir = inputs.self + "/.secrets/pyre/generated";
  };
}
