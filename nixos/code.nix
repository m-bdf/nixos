{ pkgs, ... }:

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  home = {
    home.packages = with pkgs; [ github-desktop ];

    programs.cursor = {
      enable = true;
      mutableExtensionsDir = false;

      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          github.github-vscode-theme
          mkhl.direnv
          jnoortheen.nix-ide
        ];
        userSettings = {
          "update.mode" = "none";
          "workbench.colorTheme" = "GitHub Dark Default";
          "terminal.external.linuxExec" = "xdg-terminal-exec";
          "terminal.integrated.cursorStyle" = "line";
          "terminal.integrated.cursorBlinking" = true;
          "terminal.integrated.fontLigatures.enabled" = true;
          "editor.fontLigatures" = true;
          "nix.enableLanguageServer" = true;
        };
      };
    };

    xdg = {
      configFile = {
        "GitHub Desktop".persist = true;
        "Cursor".persist = true;
      };
      dataFile.keyrings.persist = true;
    };
    home.file.".cursor".persist = true;
  };
}
