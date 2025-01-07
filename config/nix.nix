{ lib, pkgs, ... }:

{
  system.stateVersion = lib.trivial.release;

  nixpkgs.overlays = [
    (final: prev: {
      nix = final.nixVersions.latest;
    })
  ];

  nix.settings = {
    use-xdg-base-directories = true;
    auto-optimise-store = true;

    experimental-features =
    let
      xp-features = pkgs.runCommandLocal "dump-xp-features" {}
        "${lib.getExe pkgs.nix} __dump-xp-features > $out";
    in
      lib.attrNames (lib.importJSON xp-features);
  };

  programs.nh.enable = true;

  xdg.dirs = {
    data.nix.persist = true; # REPL history
    cache.nix.persist = true; # tarballs
  };
}
