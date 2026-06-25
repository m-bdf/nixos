{ config, pkgs, ... }:

let
  zed-editor = pkgs.zed-editor-fhs.overrideAttrs (prev: {
    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

    buildCommand = prev.buildCommand + ''
      wrapProgram $out/bin/zeditor \
        --set XDG_DATA_HOME '${config.home.xdg.stateHome}'
    '';
  });
in

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  home = {
    home.packages = with pkgs; [ github-desktop ];

    programs.zed-editor = {
      enable = true;
      package = zed-editor;
      extensions = [ "nix" "toml" "ini" ];

      mutableUserSettings = false;
      mutableUserKeymaps = false;
      mutableUserTasks = false;
      mutableUserDebug = false;

      userSettings = {
        close_panel_on_toggle = true;
        project_panel.dock = "left";
        outline_panel.button = false;
        collaboration_panel.button = false;
        debugger.button = false;

        git_panel = {
          dock = "left";
          tree_view = true;
          status_style = "label_color";
        };
        git = {
          hunk_style = "unstaged_hollow";
          inline_blame.show_commit_summary = true;
        };
        terminal = {
          button = false;
          shell.program = "xdg-terminal-exec";
        };
        agent = {
          dock = "right";
          sidebar_side = "right";
        };

        code_lens = "on";
        inlay_hints.enabled = true;
        diagnostics.inline.enabled = true;
        session.trust_all_worktrees = true;
        languages.Nix.language_servers = [ "nixd" ];
        format_on_save = "off";
      };
    };

    xdg = {
      configFile."GitHub Desktop".persist = true;
      dataFile.keyrings.persist = true;
      stateFile.zed = {
        persist = true;
        executable = true;
      };
    };
  };
}
