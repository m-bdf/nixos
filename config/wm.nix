{ lib, pkgs, ... }:

{
  programs.river = {
    enable = true;
    xwayland.enable = false;
    extraPackages = [];
  };

  environment.etc."xdg/river/init".source =
    pkgs.writeShellScript "river.init" ''
      systemctl --user is-active graphical-session.target && exit
      trap "
        systemctl --user unset-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        systemctl --user stop nixos-fake-graphical-session.target
      " EXIT
      systemctl --user import-environment WAYLAND_DISPLAY
      systemctl --user set-environment XDG_CURRENT_DESKTOP=river
      systemctl --user start nixos-fake-graphical-session.target

      for name in $(riverctl list-inputs | grep 'Touchpad\|Synaptics'); do
        riverctl input $name natural-scroll enabled
        riverctl input $name tap enabled
      done

      riverctl map normal Super+Alt Left send-to-output previous
      riverctl map normal Super+Alt Right send-to-output next

      for i in $(seq 1 9); do
        tags=$((1 << ($i - 1)))
        riverctl map normal Super $i set-focused-tags $tags
        riverctl map normal Super+Alt $i set-view-tags $tags
      done

      riverctl map normal Super Return spawn ${lib.getExe pkgs.fuzzel}
      riverctl map normal Super Tab spawn \
        "riverctl resize horizontal 0 && riverctl toggle-float && riverctl zoom"
      riverctl map normal Super Backspace close
      riverctl map normal Super Escape exit

      ${lib.getExe pkgs.swaybg} --image ${builtins.fetchurl {
        url = "weasyl.com/~melynx/submissions/1182575/melynx-sylveon-garden.png";
        sha256 = "0dgxkksv6cr5s3pyh9j8apd2xbjksix8km8zs4n278jpdfhlrgm5";
      }} --mode fill &

      riverctl default-layout rivertile
      rivertile
    '';
}
