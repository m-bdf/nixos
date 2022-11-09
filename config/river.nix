{ config, pkgs, ... }:

let
  riverNoX = pkgs.river.override { xwaylandSupport = false; };

  init =
  let
    inherit (config.environment) defaultTerminal defaultBrowser;
  in
    pkgs.writeShellScript "init" ''
      export PATH+=:${riverNoX}/bin XDG_CURRENT_DESKTOP=river
      variables="WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP"
      systemctl --user is-active graphical-session.target && riverctl exit
      trap "
        systemctl --user unset-environment $variables
        systemctl --user stop graphical-session.target
      " EXIT
      systemctl --user import-environment $variables
      systemctl --user start graphical-session.target

      riverctl map normal Alt Return spawn "${defaultTerminal}"
      riverctl map normal Super Return spawn "${defaultBrowser}"

      riverctl map normal Alt Tab zoom

      for i in $(seq 1 9); do
        tags=$((1 << ($i - 1)))
        riverctl map normal Alt $i set-focused-tags $tags
        riverctl map normal Super $i set-view-tags $tags
      done

      riverctl map normal Alt Backspace close
      riverctl map normal Super Escape exit

      riverctl default-layout rivertile
      rivertile
    '';
in

{
  environment = {
    systemPackages = [ riverNoX ];
    shellAliases.river = "session-run river";
    etc."river/init".source = init;
  };

  hardware.opengl.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    #pulse.enable = true;
  };

  xdg.portal = {
    wlr.enable = true;
    #gtkUsePortal = true;
  };

  services = {
    localtimed.enable = true;
  };
  location.provider = "geoclue2";
}
