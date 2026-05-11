{ inputs, pkgs, ... }:

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs.overlays = [ inputs.vscode-extensions.overlays.default ];

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
          "terminal.external.linuxExec" = "xdg-terminal-exec";
          "terminal.integrated.cursorStyle" = "line";
          "terminal.integrated.cursorBlinking" = true;
          "terminal.integrated.fontLigatures.enabled" = true;
          "editor.fontLigatures" = true;
          "workbench.colorTheme" = "GitHub Dark Default";
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
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
