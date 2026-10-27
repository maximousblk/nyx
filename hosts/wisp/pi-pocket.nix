{
  config,
  inputs,
  lib,
  modx,
  pkgs,
  ...
}:
{
  imports = [
    "${inputs.pi-pocket}/nix/module.nix"
    modx.nixos.tailscale-services
  ];

  topology.self.services.pi-pocket = {
    name = "Pi Pocket";
    info = "Mobile coding-agent workspace";
  };

  services.pi-pocket = {
    enable = true;
    package = pkgs.pi-pocket;
    user = "maximousblk";
    group = "users";
    cwd = "/home/maximousblk";
    access = "local";
    browser = "${pkgs.chromium}/bin/chromium";
    browserArgs = [ "--no-sandbox" ];
    extraPackages = [
      pkgs.git
      pkgs.openssh
      pkgs.ripgrep
    ];
  };

  # Merge declarative NixOS variables; retain upstream service-specific values.
  systemd.services.pi-pocket = {
    environment = lib.mapAttrs (_: value: lib.mkDefault (if builtins.isList value then lib.concatStringsSep ":" value else toString value)) (
      builtins.removeAttrs (config.environment.variables // config.environment.sessionVariables) [ "PATH" ]
    );
    path =
      let
        user = config.services.pi-pocket.user;
        home = config.users.users.${user}.home;
        expand =
          lib.replaceStrings
            [ "\${XDG_STATE_HOME}" "$XDG_STATE_HOME" "\${HOME}" "$HOME" "\${USER}" "$USER" ]
            [ "${home}/.local/state" "${home}/.local/state" home home user user ];
      in
      lib.mkAfter (lib.unique ([ (builtins.dirOf config.security.wrapperDir) ] ++ map expand config.environment.profiles));
  };

  # Pi custom endpoints consume models.json rather than discovering /models themselves.
  systemd.services.pi-pocket.preStart = lib.mkBefore ''
    registry="$HOME/.pi/agent/models.json"
    catalog=$(mktemp)
    generated=$(mktemp "$HOME/.pi/agent/.models.XXXXXX")
    trap 'rm -f "$catalog" "$generated"' EXIT
    ${pkgs.curl}/bin/curl --fail --silent --show-error --max-time 30 \
      https://aperture.pony-clownfish.ts.net/v1/models > "$catalog"
    ${pkgs.jq}/bin/jq -e '{providers: {aperture: {
      baseUrl: "https://aperture.pony-clownfish.ts.net/v1",
      api: "openai-responses",
      apiKey: "tailnet",
      models: [.data[] | select(.supported_endpoints | index("/v1/responses")) | {
        id, name: (.display_name // .id),
        contextWindow: .context_window_tokens,
        maxTokens: .max_output_tokens,
        reasoning: true, input: ["text", "image"]
      }]
    }}} | select(.providers.aperture.models | length > 0)' "$catalog" > "$generated"
    chmod 600 "$generated"
    mv -f "$generated" "$registry"
  '';

  # Pi Pocket uses Pi's model registry, not OMP's provider configuration.
  systemd.tmpfiles.rules = [
    "d /home/maximousblk/.pi 0700 maximousblk users -"
    "d /home/maximousblk/.pi/agent 0700 maximousblk users -"
    "L+ /home/maximousblk/.pi/agent/settings.json - - - - ${
      (pkgs.formats.json { }).generate "pi-pocket-settings.json" {
        defaultProvider = "aperture";
        defaultModel = "openai-codex/gpt-5.6-luna";
        defaultThinkingLevel = "medium";
      }
    }"
  ];

  optx.tailscale.services.pocket = {
    serve."https:443" = "http://localhost:8787";
    backends = [ "pi-pocket.service" ];
  };
}
