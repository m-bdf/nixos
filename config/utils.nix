{ lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs;
      [ uutils-coreutils-noprefix fd ripgrep helix xdg-utils /*ghostty*/kitty /*zen-browser*/brave ];

    etc."xdg/kitty/kitty.conf".text = ''
      shell_integration enabled
      enable_audio_bell no
      confirm_os_window_close 0
    '';

    variables = {
      EDITOR = "hx";
      NIXOS_OZONE_WL = "1";
    };
  };

  programs.river.bindings = [{
    mod = "Super";
    key = "Return";
    cmd = lib.getExe pkgs.fuzzel;
  }];

  xdg = {
    terminal-exec = {
      enable = true;
      package = pkgs.xdg-terminal-exec-mkhl;
    };

    dirs = {
      config."BraveSoftware/Brave-Browser".persist = true;
      cache = {
        helix.create = true;
        kitty.create = true;
        "BraveSoftware/Brave-Browser".create = true;
      };
    };
  };
}
