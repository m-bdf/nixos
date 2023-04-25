{ config, lib, pkgs, nix-index-database, ... }:

{
  users.users.user.shell =
  let
    fish-wrapper = pkgs.writeShellScriptBin "fish-wrapper"
      ". /etc/set-environment && exec ${lib.getExe pkgs.fish}";
  in
    lib.getExe fish-wrapper;

  programs = {
    fish = {
      enable = true;
      useBabelfish = true;
    };
    command-not-found.enable = false;

    starship = {
      enable = true;
      settings =
      let
        preset = pkgs.runCommandLocal "starship-nerd-font-preset" {}
          "${lib.getExe pkgs.starship} preset nerd-font-symbols > $out";
      in
        lib.importTOML preset;
    };
  };

  imports = [ nix-index-database.nixosModules.nix-index ];

  environment = {
    systemPackages = [
      (pkgs.comma.override {
        nix-index-unwrapped = config.programs.nix-index.package;
      })
    ];

    sessionVariables = {
      STARSHIP_CACHE = "/var/cache/starship"; #starship/896
    };
  };

  fonts.fonts = [
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  xdg.dirs = {
    config.fish.create = true; # variables
    data.fish.persist = true; # history
    cache.starship.create = true; # logs
  };
}
