{ pkgs, ... }:

{
  programs = {
    gtklock = {
      enable = true;
      modules = with pkgs; [
        gtklock-powerbar-module
        gtklock-playerctl-module
      ];

      package = pkgs.gtklock.overrideAttrs {
        prePatch = ''
          show='gtk_label_set_text(GTK_LABEL(ctx->warning_label), \1());'
          sed -zi "s/{[^{]*\(auth_get\w*\)[^}]*}/$show/g" src/window.c
        '';
      };

      config = {
        main = {
          time-format = "%X";
          date-format = "%A %d %B %Y";
        };
        powerbar = {
          suspend-command = "";
          logout-command = "loginctl terminate-session";
        };
      };
    };

    niri = {
      startup = "gtklock";
      keybinds.XF86AudioMedia = "spawn \"gtklock\"";
    };
  };

  xdg.dirs.state.fprint.persist = true;
}
