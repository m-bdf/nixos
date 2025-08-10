{ inputs, options, lib, pkgs, ... }:

{
  imports = [
    (lib.mkAliasOptionModule [ "home" ] [ "home-manager" "config" ])
  ];

  user = {
    userName = "mae";
    shell = pkgs.fish;
  };

  system.stateVersion = lib.last
    options.system.stateVersion.type.functor.payload.values;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs.inputs = inputs;
  };

  home = {
    nix.settings = {
      use-xdg-base-directories = lib.mkForce false;
      auto-optimise-store = lib.mkForce false;
    };
    programs.nh.enable = lib.mkForce false;
  };
}
