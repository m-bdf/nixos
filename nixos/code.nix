{ pkgs, ... }:

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  programs.nix-ld.enable = true;

  home = {
    home.packages = with pkgs; [ github-desktop ];

    programs.zed-editor = {
      enable = true;
      extensions = [ "nix" "toml" ];

      mutableUserSettings = false;
      mutableUserKeymaps = false;
      mutableUserTasks = false;
      mutableUserDebug = false;

      userSettings = {
        project_panel.dock = "left";
        outline_panel.button = false;
        collaboration_panel.button = false;
        git_panel.dock = "left";

        agent = {
          dock = "right";
          sidebar_side = "right";
        };
        close_panel_on_toggle = true;

        debugger.button = false;
        terminal = {
          button = false;
          shell.program = "xdg-terminal-exec";
        };

        code_lens = "on";
        inlay_hints.enabled = true;
        diagnostics.inline.enabled = true;
        session.trust_all_worktrees = true;
        languages.Nix.language_servers = [ "nixd" ];
      };
    };

    xdg = {
      configFile."GitHub Desktop".persist = true;
      dataFile = {
        keyrings.persist = true;
        zed = {
          persist = true;
          executable = true;
        };
      };
    };
  };
}
