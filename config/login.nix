{ inputs, config, pkgs, ... }:

{
  services = {
    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;

    kmscon = {
      enable = true;
      hwRender = true;
    };

    greetd = {
      enable = true;
      settings.default_session = {
        user = config.users.users.user.name;
        command = "niri-session 2>/dev/null";
      };
    };
  };

  environment.etc."xdg/niri/config.kdl".text = ''
    spawn-at-startup "gtklock"
  '';

  imports = [
    (inputs.gtklock + /nixos/modules/programs/wayland/gtklock.nix)
  ];

  programs = {
    gtklock = {
      enable = true;
      modules = with pkgs; [
        gtklock-powerbar-module
        gtklock-playerctl-module
      ];
    };

    niri.bindings.XF86AudioMedia = "spawn \"gtklock\"";
  };

  xdg.dirs.state.fprint.persist = true;
}
