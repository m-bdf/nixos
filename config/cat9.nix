{ pkgs, ... }:

let
  cat9 = pkgs.writeShellScriptBin "cat9" ''
    arcan=${pkgs.arcanPackages.cat9-wrapped}
    LASH_BASE=$arcan/share/arcan/appl/cat9 \
    LASH_SHELL=cat9 $arcan/bin/arcan console lash
  '';
in

{
  environment = {
    systemPackages = [ cat9 ];
    #defaultTerminal = "cat9";
  };
}
