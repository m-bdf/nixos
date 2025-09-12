{ inputs, lib, pkgs, ... }:

{
  nix = {
    package = lib.mkDefault pkgs.nix;

    settings = {
      use-xdg-base-directories = true;
      flake-registry = "";
      lazy-locks = true;
      lazy-trees = true;
      eval-cores = 0;
      auto-allocate-uids = true;
      use-cgroups = true;
      keep-outputs = true;
    };

    extraOptions =
    let
      features = with pkgs;
        runCommandLocal "features.conf" {
          nativeBuildInputs = [ nix jq ];
        } ''
          (nix __dump-xp-features && ${lib.getExe nix} __dump-xp-features) |
            jq -r '"extra-experimental-features = \(keys | join(" "))"' > $out
          ${lib.getExe nix} config show | grep system-features >> $out
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
