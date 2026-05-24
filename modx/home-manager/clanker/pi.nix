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
  baseSettings = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.5";
    defaultThinkingLevel = "medium";
    enableInstallTelemetry = false;
    theme = "terminal-tinted";
  };
  globalExtensionSettings = {
    extensions = [
      pkgx.pi-commandcode-provider.extention
      pkgx.pi-mcp-adapter.extention
      pkgx.pi-web-access.extention
      pkgx.pi-context-mode.extention
    ]
    ++ (cfg.settings.extensions or [ ]);
    skills = [
      pkgx.pi-web-access.skills
      pkgx.pi-context-mode.skills
    ]
    ++ (cfg.settings.skills or [ ]);
    themes = [ pkgx.pi-terminal-theme.themes ] ++ (cfg.settings.themes or [ ]);
  };
  userSettingsSansGlobalResources = builtins.removeAttrs cfg.settings [
    "extensions"
    "skills"
    "themes"
  ];
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
      ".pi/agent/settings.json".source = jsonFormat.generate "pi-settings.json" (baseSettings // userSettingsSansGlobalResources // globalExtensionSettings);

      ".pi/agent/AGENTS.md".source = ./AGENTS.md;
      ".pi/agent/skills".source = ./skills;
      ".pi/agent/extensions".source = ./extensions;
      ".pi/agent/prompts".source = ./prompts;
      ".pi/agent/themes".source = ./themes;
    };
  };
}
