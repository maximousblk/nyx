{
  config,
  inputs,
  lib,
  modx,
  pkgx,
  pkgs,
  self,
  ...
}:
let
  orca = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca;
  profile = config.home-manager.users.orca.home.profileDirectory;
in
{
  imports = [ modx.nixos.tailscale-services ];

  topology.self.services.orca = {
    name = "Orca";
    info = "Remote coding-agent runtime";
    icon = pkgx.topology-icons.orca;
  };

  users.groups.orca = { };
  users.users.orca = {
    isSystemUser = true;
    group = "orca";
    extraGroups = [ "wheel" ];
    home = "/var/lib/orca";
    createHome = true;
    shell = pkgs.bashInteractive;
  };

  home-manager.users.orca = {
    imports = [ modx.hm.clanker ];
    nixpkgs = self.nixpkgsConfig;
    home.stateVersion = "26.05";
    optx.clanker.omp = {
      enable = true;
      memory.backend = "mnemopi";
      modelRoles = {
        advisor = "aperture-responses/openai-codex/gpt-5.6-terra:low";
        commit = "aperture-responses/openai-codex/gpt-5.6-luna:low";
        default = "aperture-responses/openai-codex/gpt-5.6-terra:low";
        designer = "aperture-responses/openai-codex/gpt-5.6-terra:low";
        plan = "aperture-responses/openai-codex/gpt-5.6-terra:low";
        slow = "aperture-responses/openai-codex/gpt-5.6-sol:low";
        smol = "aperture-responses/openai-codex/gpt-5.6-luna:low";
        task = "aperture-responses/openai-codex/gpt-5.6-terra:low";
        tiny = "aperture-responses/openai-codex/gpt-5.6-luna:low";
        vision = "aperture-responses/openai-codex/gpt-5.6-luna:low";
      };
    };
  };

  environment.systemPackages = [
    orca
    pkgs.git
  ];

  systemd.services.orca = {
    description = "Orca headless runtime";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "tailscaled.service"
    ];
    requires = [ "home-manager-orca.service" ];
    after = [
      "home-manager-orca.service"
      "network-online.target"
      "tailscaled.service"
    ];
    path = [
      pkgs.systemd
      pkgs.git
    ];
    environment.PATH = lib.mkOverride 40 "${profile}/bin:${
      lib.makeBinPath [
        pkgs.systemd
        pkgs.git
      ]
    }:${config.system.path}/bin";
    environment.PUPPETEER_EXECUTABLE_PATH = config.home-manager.users.orca.home.sessionVariables.PUPPETEER_EXECUTABLE_PATH;
    startLimitIntervalSec = 300;
    startLimitBurst = 5;
    serviceConfig = {
      User = "orca";
      Group = "orca";
      WorkingDirectory = "/var/lib/orca";
      Environment = [
        "LIBGL_ALWAYS_SOFTWARE=1"
        "HOME=/var/lib/orca"
      ];
      ExecStart = "${orca}/bin/orca serve --port 6768 --pairing-address https://orca.pony-clownfish.ts.net";
      Restart = "on-failure";
      RestartPreventExitStatus = 3;
      RestartSec = 5;
      KillMode = "mixed";
    };
  };

  # Orca's detached terminal daemon must outlive service restarts.
  systemd.tmpfiles.rules = [
    "d /var/lib/orca 0750 orca orca -"
    "d /var/lib/systemd/linger 0755 root root -"
    "f /var/lib/systemd/linger/orca 0644 root root -"
  ];

  optx.tailscale.services.orca = {
    serve."https:443" = "http://localhost:6768";
    backends = [ "orca.service" ];
  };
}
