{ inputs, lib, pkgs, ... }:

{
  nix = {
    package = lib.mkDefault pkgs.nix;

    settings = {
      use-xdg-base-directories = true;
      flake-registry = "";
      lazy-locks = true;
      lazy-trees = true;
      auto-allocate-uids = true;
      use-cgroups = true;
      keep-outputs = true;
    };

    extraOptions =
    let
      features = pkgs.runCommandLocal "features.conf" {
        nativeBuildInputs = with pkgs; [ nix jq ];
      } ''
        nix --offline --experimental-features "$(
          nix __dump-xp-features | jq -r 'keys[]'
        )" config show | grep features > $out
      '';
    in
      "include ${features}";

    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    keepOldNixPath = false;
  };

  programs.nh.enable = true;

  xdg = {
    cacheFile.nix.persist = true; # tarballs
    dataFile.nix.persist = true; # REPL history
  };
}
