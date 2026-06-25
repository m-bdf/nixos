{ config, lib, ... }:

let
  actions = {
    "Mod+Prior" = "focus-workspace 0";
    "Mod+Up" = "focus-workspace-up";
    "Mod+Down" = "focus-workspace-down";
    "Mod+Next" = "focus-workspace 255";
    "Mod+Home" = "focus-column-first";
    "Mod+Left" = "focus-column-left";
    "Mod+Right" = "focus-column-right";
    "Mod+End" = "focus-column-last";

    "Super+Alt+Prior" = "move-workspace-up";
    "Super+Alt+Up" = "move-column-to-workspace-up";
    "Super+Alt+Down" = "move-column-to-workspace-down";
    "Super+Alt+Next" = "move-workspace-down";
    "Super+Alt+Home" = "move-column-to-first";
    "Super+Alt+Left" = "move-column-left";
    "Super+Alt+Right" = "move-column-right";
    "Super+Alt+End" = "move-column-to-last";

    "Mod+Tab" = "switch-preset-window-width";
    "Super+Alt+Tab" = "toggle-window-floating";
    "Mod+Backspace" = "close-window";

    "Print" = "screenshot";
  };
in

{
  home-manager.sharedModules = [{
    options.wayland.keybinds = lib.mkOption {
      type = with lib.types; attrsOf nonEmptyStr;
      apply = lib.mapAttrs (keys: cmd: ''spawn-sh "${cmd}"'');
    };
  }];

  home.xdg.configFile."niri/config.kdl".text = ''
    binds {
      ${lib.concatMapAttrsStringSep "\n  "
        (keys: action: "${keys} { ${action}; }")
        (actions // config.home.wayland.keybinds)}
    }

    hotkey-overlay { skip-at-startup; }
    screenshot-path "~/Downloads/Screenshot %c.png"
  '';
}
