{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  options.optx.clanker.fx.enable = lib.mkEnableOption "fx coding agent";

  config = lib.mkIf config.optx.clanker.fx.enable { home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.fx ]; };
}
