{
  lib,
  pkgs,
  config,
  pkgx,
  inputs,
  ...
}:
let
  cfg = config.optx.clanker.claude;
in
{
  options.optx.clanker.claude.enable = lib.mkEnableOption "claude-code with MCP integration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgx.split-commit.package ];
    home.file.".claude/skills/split-commit/SKILL.md".source = "${pkgx.split-commit.package}/share/skills/split-commit/SKILL.md";
    home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";
    programs.claude-code = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      enableMcpIntegration = true;
      settings = {
        model = "sonnet";
        effortLevel = "low";
        permissions = {
          allow = [ ];
          defaultMode = "plan";
        };
      };
    };

    home.file."${config.home.homeDirectory}/.claude/settings.json".force = true;
  };
}
