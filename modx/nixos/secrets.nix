{
  config,
  self,
  inputs,
  ...
}:
let
  name = config.networking.hostName;
  secretsBase = inputs.self + "/.secrets";
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age.rekey = {
    hostPubkey = builtins.readFile (secretsBase + "/${name}/host.pub");
    inherit (self.secretsConfig) masterIdentities extraEncryptionPubkeys;
    storageMode = "local";
    localStorageDir = secretsBase + "/${name}/rekeyed";
    generatedSecretsDir = secretsBase + "/${name}/generated";
    secretsDir = secretsBase + "/${name}/manual";
  };
}
