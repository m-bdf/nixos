{ inputs, config, lib, pkgs, ... }:

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

    # fprintd.package = pkgs.fprintd.overrideAttrs {
    #   # prePatch = ''
    #   #   sed -i "/pam_dep /i pthread_dep = dependency('threads')" meson.build
    #   #   sed -i "/pam_dep,/i pthread_dep," pam/meson.build
    #   #   cp ${../pam_fprintd_grosshack.c} pam/pam_fprintd.c
    #   # '';

    #   postInstall = ''
    #     cp ${pkgs.pam-any}/lib/security/pam_any.so \
    #       $out/lib/security/pam_fprintd.so # wrapper with hardcoded arguments?
    #   '';
    # };
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

  security.pam.services = {
    sudo.rules.auth.fprintd = {
      modulePath = lib.mkForce "${pkgs.pam-any}/lib/security/libpam_any.so";
      args = [
        (builtins.toJSON {
          mode = "One";
          modules = {
            passwd = "Password";
            greetd = "Fingerprint";
          };
        })
      ];
    };

    passwd.fprintAuth = false;
  };

  xdg.dirs.state.fprint.persist = true;
}
