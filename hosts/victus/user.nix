{
  pkgs,
  pkgx,
  modx,
  self,
  inputs,
  ...
}:
{
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

      openssh.authorizedKeys.keyFiles = [ inputs.ssh-keys-maximousblk ];
    };

    home-manager = {
      users.maximousblk = {
        imports = [ self.homeProfiles.victus ];
      };
    };
  };
}
