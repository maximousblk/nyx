{
  lib,
  pkgs,
  config,
  pkgx,
  ...
}:
let
  cfg = config.optx.clanker.pi;
  jsonFormat = pkgs.formats.json { };
in
{
  options.optx.clanker.pi = {
    enable = lib.mkEnableOption "pi coding agent";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.llm-agents.pi ];

    home.sessionVariables = {
      PI_TELEMETRY = "0";
      PI_SKIP_VERSION_CHECK = "1";
    };

    home.file = {
      ".pi/agent/settings.json".source = jsonFormat.generate "pi-settings.json" {
        defaultProvider = "opencode-go";
        defaultModel = "deepseek-v4-pro";
        defaultThinkingLevel = "medium";
        enabledModels = [
          "openai-codex/gpt-5.5"
          "opencode-go/deepseek-v4-pro"
          "opencode-go/mimo-v2.5-pro"
        ];
        enableInstallTelemetry = false;
        extensions = [
          "${pkgs.herdr.src}/src/integration/assets/pi/herdr-agent-state.ts"
          pkgx.pi-web-access.extention
          pkgx.pi-context-mode.extention
        ];
      };

      ".pi/agent/extensions".source = ./pi-extensions;
    };
  };
}
