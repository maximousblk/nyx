{ ... }:
{
  config = {
    programs.opencode = {
      enable = true;
      settings = {
        theme = "rosepine";
        model = "opencode/big-pickle";
        small_model = "opencode/big-pickle";
        autoupdate = false;
        share = "disabled";

        permission = {
          # Destructive operations - always ask
          bash = "ask";
          edit = "ask";
          write = "ask";
          patch = "ask";
          todowrite = "ask";

          # Safe operations - always allow
          read = "allow";
          grep = "allow";
          glob = "allow";
          list = "allow";
          todoread = "allow";
          webfetch = "allow";
        };
      };
    };
  };
}
