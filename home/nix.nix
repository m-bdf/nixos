{ config, lib, pkgs, ... }:

{
  nix = {
    package = lib.mkDefault pkgs.nix;

    settings = {
      use-xdg-base-directories = true;
      trusted-users = [ config.home.username ];
      flake-registry = "";
      lazy-locks = true;
      lazy-trees = true;
      eval-cores = 0;
      auto-allocate-uids = true;
      use-cgroups = true;
      auto-optimise-store = true;
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
  };

  programs.nh.enable = true;

  xdg = {
    cacheFile.nix.persist = true; # tarballs
    dataFile.nix.persist = true; # REPL history
  };
}
