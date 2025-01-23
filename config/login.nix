{ config, lib, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings.default_session.command =
      "${lib.getExe pkgs.cage} -sdm last ${lib.getExe pkgs.greetd.gtkgreet}";
  };

  environment.etc."greetd/environments".text =
    lib.concatMapStrings (session: "uwsm start ${session}.desktop\n")
      config.services.displayManager.sessionData.sessionNames;

  systemd.user.services."wayland-wm-env@" = {
    path = config.services.displayManager.sessionPackages;
    overrideStrategy = "asDropin";
  };

  programs = {
    uwsm = {
      enable = true;
      package = pkgs.uwsm.override {
        fumonSupport = false;
        uuctlSupport = false;
        uwsmAppSupport = false;
      };
      waylandCompositors = {};
    };

    niri.bindings."Mod+Escape" = "spawn \"uwsm\" \"stop\"";
  };
}
