{ config, lib, pkgs, ... }:

{
  system.stateVersion = lib.trivial.release;

  nix = {
    package = pkgs.nixVersions.latest;

    settings = {
      use-xdg-base-directories = true;
      auto-optimise-store = true;
      flake-registry = "";

      experimental-features =
      let
        xp-features = pkgs.runCommandLocal "dump-xp-features" {}
          "${lib.getExe config.nix.package} __dump-xp-features > $out";
      in
        lib.attrNames (lib.importJSON xp-features);
    };
  };

  programs.nh.enable = true;

  xdg.dirs = {
    data.nix.persist = true; # REPL history
    cache.nix.persist = true; # tarballs
  };
}
