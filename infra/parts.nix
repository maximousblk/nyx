{ inputs, ... }:
{
  flake.secretFiles = [
    ".secrets/infra/cloudflare-env.age"
    ".secrets/infra/oracle-env.age"
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      devShells.infra = pkgs.mkShell {
        nativeBuildInputs = [
          config.agenix-rekey.package
          pkgs.opentofu
          pkgs.terragrunt
          pkgs.oci-cli
        ];
        shellHook = ''
          repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
          case "$(hostname)" in
            victus) export AGENIX_REKEY_PRIMARY_IDENTITY="$(cat "$repo_root/.secrets/master_victus.pub")" ;;
            zenbook) export AGENIX_REKEY_PRIMARY_IDENTITY="$(cat "$repo_root/.secrets/master_zenbook.pub")" ;;
            *) echo "Unknown host: $(hostname), AGENIX_REKEY_PRIMARY_IDENTITY not set" >&2 ;;
          esac
          export AGENIX_REKEY_PRIMARY_IDENTITY_ONLY=true
          export NYX_SSH_AUTHORIZED_KEYS_FILE=${inputs.ssh-keys-maximousblk}

          for f in "$repo_root"/.secrets/infra/*.age; do
            [ -f "$f" ] || continue
            set -a
            source <(agenix view "$f")
            set +a
          done
          export TF_IN_AUTOMATION=1
        '';
      };
    };
}
