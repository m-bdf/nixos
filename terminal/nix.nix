{ inputs, lib, pkgs, ... }:

let
  default = pkgs.writeTextDir "default.nix" ''
    { config ? {}, ... }@ args:

    import ./pkgs/top-level/impure.nix (args // {
      config = ${
        with lib; generators.toPretty { indent = "  "; }
          (filterAttrs (_: v: !isFunction v) pkgs.config)
      } // config;
    })
  '';

  nixpkgs = pkgs.runCommand "source" {} ''
    cp -R ${inputs.nixpkgs} $out
    chmod +w $out/default.nix
    cp ${default}/* $out
  '';
in

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
          nativeBuildInputs = [ nixVersions.latest jq ];
        } ''
          { { nix __dump-xp-features && ${lib.getExe nix} __dump-xp-features
            } | jq -sr '"experimental-features = \(add | keys | join(" "))"'
            ${lib.getExe nix} --offline config show | grep system-features
          } > $out
        '';
    in
      "include ${features}";

    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    keepOldNixPath = false;
  };

  programs.nh.enable = true;

  xdg = {
    cacheFile.nix.persist = true; # tarballs
    dataFile.nix.persist = true; # REPL history
  };
}
