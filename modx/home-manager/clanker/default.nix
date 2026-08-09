{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.optx.clanker;
in
{
  imports = [
    ./llama-cpp.nix
    ./stable-diffusion-cpp.nix
    ./pi.nix
    ./omp.nix
    ./opencode.nix
    ./claude-code.nix
    ./prime-agent.nix
  ];

  options.optx.clanker.ollama = {
    enable = lib.mkEnableOption "Ollama local LLM service";
    acceleration = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          false
          "rocm"
          "cuda"
        ]
      );
      default = false;
      description = "Hardware acceleration for Ollama (false, \"rocm\", or \"cuda\").";
    };
  };

  config = lib.mkMerge [
    {
      programs.mcp = {
        enable = true;
        servers = {
          gh_grep.url = "https://mcp.grep.app";
          context7.url = "https://mcp.context7.com/mcp";
          lightpanda = {
            command = lib.getExe pkgs.nur.repos.xddxdd.lightpanda;
            args = [ "mcp" ];
          };
        };
      };
    }

    (lib.mkIf cfg.ollama.enable {
      services.ollama = {
        enable = true;
        acceleration = cfg.ollama.acceleration;
      };
    })
  ];
}
