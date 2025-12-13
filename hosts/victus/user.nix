{
  pkgs,
  pkgx,
  modx,
  self,
  inputs,
  ...
}:
let
  github_keys = pkgs.fetchurl {
    url = "https://github.com/maximousblk.keys";
    hash = "sha256-D98WDUJcwRVZtHzp3FNzJXnKzjX7fzxzsQV2sZKV3oA=";
  };
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = {
    users.users.maximousblk = {
      description = "Maximous Black";
      isNormalUser = true; # debatable
      linger = false;

      extraGroups = [
        "networkmanager"
        "wheel"
        "render"
        "uinput"
        "video"
      ];

      openssh.authorizedKeys.keyFiles = [ github_keys ];
    };

    home-manager = {
      users.maximousblk = {
        imports = [ self.homeProfiles.victus ];
      };
      extraSpecialArgs = { inherit inputs pkgx modx; };

      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm_bak";
    };
  };
}
