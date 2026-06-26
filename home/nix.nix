{ lib, pkgs, ... }:

{
  nix = {
    package = lib.mkDefault pkgs.nix;

    settings = {
      use-xdg-base-directories = true;
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
          nativeBuildInputs = [ nix jaq ];
        } ''
          nix --offline --experimental-features "$(
            nix __dump-xp-features | jaq -r 'keys[]'
          )" config show | grep features > $out
        '';
    in
      lib.readFile features;
  };

  programs.nh.enable = true;

  xdg = {
    cacheFile.nix.persist = true; # tarballs
    dataFile.nix.persist = true; # REPL history
  };
}
