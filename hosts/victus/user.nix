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

      openssh.authorizedKeys.keyFiles = [
        inputs.ssh-keys-maximousblk
        (self + "/hosts/cairn/zerobyte.pub")
      ];
    };

    home-manager = {
      users.maximousblk = {
        imports = [
          (self.homeProfiles.victus {
            username = "maximousblk";
            homeDirectory = "/home/maximousblk";
          })
        ];
      };
    };
  };
}
