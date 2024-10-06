{ lib, ... }:

with lib;

{
  options.programs.river.bindings = mkOption {
    type = with types; listOf (submodule {
      options = {
        mod = mkOption { type = nullOr nonEmptyStr; default = null; };
        key = mkOption { type = nonEmptyStr; };
        cmd = mkOption { type = nonEmptyStr; };
        rep = mkEnableOption "repeating cmd until key release";
      };
    });
  };

  config.programs.river.bindings = concatMap (i: [
    {
      mod = "Super";
      key = toString i;
      cmd = "riverctl set-focused-tags $((1 << (${toString i} - 1)))";
    }
    {
      mod = "Super+Alt";
      key = toString i;
      cmd = "riverctl set-view-tags $((1 << (${toString i} - 1)))";
    }
  ]) (range 1 9) ++ [
    {
      mod = "Super+Alt";
      key = "Left";
      cmd = "riverctl send-to-output previous";
    }
    {
      mod = "Super+Alt";
      key = "Right";
      cmd = "riverctl send-to-output next";
    }
    {
      mod = "Super";
      key = "Tab";
      cmd = "riverctl resize horizontal 0 && riverctl toggle-float && riverctl zoom";
    }
    {
      mod = "Super";
      key = "Backspace";
      cmd = "riverctl close";
    }
  ];
}
