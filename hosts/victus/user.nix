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
      openssh.authorizedKeys.keys = [
        # Dedicated Zerobyte SFTP key from cairn for pull-based source access.
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNtBMxtsvxn6H7wPhSULYDVjagLo/KKcREs/obCz/4K maximousblk@victus"
      ];
    };

    home-manager = {
      users.maximousblk = {
        imports = [
          (self.homeProfiles.mkVictus {
            username = "maximousblk";
            homeDirectory = "/home/maximousblk";
          })
        ];
      };
    };
  };
}
