{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.optx.clanker.pi;
  jsonFormat = pkgs.formats.json { };
in
{
  options.optx.clanker.pi = {
    enable = lib.mkEnableOption "pi-coding-agent";

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "Extra settings merged into ~/.pi/agent/settings.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.llm-agents.pi ];

    home.sessionVariables = {
      PI_CODING_AGENT_SESSION_DIR = "${config.xdg.stateHome}/pi/sessions";
      PI_TELEMETRY = "0";
      PI_SKIP_VERSION_CHECK = "1";
    };

    home.file = {
      ".pi/agent/settings.json".source = jsonFormat.generate "pi-settings.json" (
        {
          defaultProvider = "openai-codex";
          defaultModel = "gpt-5.5";
          defaultThinkingLevel = "medium";
          enableInstallTelemetry = false;
        }
        // cfg.settings
      );

      ".pi/agent/AGENTS.md".source = ./AGENTS.md;
      ".pi/agent/skills".source = ./skills;
      ".pi/agent/extensions".source = ./extensions;
      ".pi/agent/prompts".source = ./prompts;
      ".pi/agent/themes".source = ./themes;
    };
  };
}
