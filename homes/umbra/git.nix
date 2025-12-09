{ config, pkgs, ... }:
let
  name = "Ashwin Kumar Yadav";
  email = "ashwin.y@aftershoot.com";
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSpQilijYbfQ3wclSXCcW1iQlDukBtG84Vhmvp3hkZ2 ashwin_y@zenbook";

  signers = pkgs.writeText "git-allowed-signers" ''
    ${email} namespaces="git" ${pubkey}
  '';
in
{
  config = {

    xdg.configFile."git/allowed_signers".source = signers;

    programs.git = {
      enable = true;

      signing = {
        format = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        signByDefault = true;
      };

      settings = {
        user.name = name;
        user.email = email;

        aliases.pullauto = "pull --rebase --autostash";

        gpg.ssh.allowedSignersFile = "${signers}";
        url = {
          "git@github.com:aftershootco/aftershoot-cloud" = {
            insteadOf = "https://github.com/aftershootco/aftershoot-cloud";
          };
        };
      };
    };

    programs.difftastic = {
      enable = true;
      git.enable = true;
      git.diffToolMode = true;
      options = {
        display = "inline";
        sort-paths = true;
      };
    };

  };
}
