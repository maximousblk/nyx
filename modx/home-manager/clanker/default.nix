{ lib, config, ... }:
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
    ./omp-auth.nix
    ./fx.nix
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

  config = lib.mkIf cfg.ollama.enable {
    services.ollama = {
      enable = true;
      acceleration = cfg.ollama.acceleration;
    };
  };
}
