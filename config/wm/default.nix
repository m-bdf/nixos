{ config, lib, pkgs, ... }:

{
  imports = [ ./binds.nix ];

  nixpkgs.overlays = [
    (final: prev: {
      xwayland = null;
      wlroots_0_17 = prev.wlroots_0_17.override { enableXWayland = false; };
      wlroots_0_18 = prev.wlroots_0_18.override { enableXWayland = false; };
    })
  ];

  programs.river = {
    enable = true;
    xwayland.enable = false;
    extraPackages = [ pkgs.qt5.qtwayland ];
  };

  environment = {
    etc."xdg/river/init".source = pkgs.writeShellScript "river.init" ''
      uwsm finalize

      for name in $(riverctl list-inputs | grep 'Touchpad\|Synaptics'); do
        riverctl input $name natural-scroll enabled
        riverctl input $name tap enabled
      done

      ${lib.concatMapStringsSep "\n" ({ mod, key, cmd, rep }: ''
        riverctl map ${lib.optionalString rep "-repeat"} \
          normal ${lib.defaultTo "None" mod} ${key} spawn '${cmd}'
      '') config.programs.river.bindings}

      ${lib.getExe pkgs.swaybg} --image ${builtins.fetchurl {
        url = "weasyl.com/~melynx/submissions/1182575/melynx-sylveon-garden.png";
        sha256 = "0dgxkksv6cr5s3pyh9j8apd2xbjksix8km8zs4n278jpdfhlrgm5";
      }} --mode fill &

      riverctl default-layout rivertile
      rivertile
    '';

    variables.NIXOS_OZONE_WL = "1";
  };
}
