{
  pkgs,
  pkgx,
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

      packages = with pkgs; [
        nil
        nixd
        zed-editor
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.maximousblk = import ./home/default.nix;
      extraSpecialArgs = { inherit inputs pkgx; };
    };
  };
}
