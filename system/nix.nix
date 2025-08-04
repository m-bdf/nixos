{ inputs, lib, pkgs, ... }:

{
  nix = {
    package = inputs.nix.packages.${pkgs.stdenv.system}.nix;

    channel.enable = false;
    settings = {
      use-xdg-base-directories = true;
      flake-registry = "";
      lazy-locks = true;
      lazy-trees = true;
      auto-allocate-uids = true;
      use-cgroups = true;
      auto-optimise-store = true;
      keep-outputs = true;
    };

    extraOptions =
    let
      features = pkgs.runCommandLocal "features.conf" {
        nativeBuildInputs = with pkgs; [ nix jq ];
      } ''
        nix --experimental-features "$(
          nix __dump-xp-features | jq -r 'keys[]'
        )" config show | grep features > $out
      '';
    in
      "include ${features}";
  };

  programs.nh.enable = true;
  system = {
    disableInstallerTools = true;
    stateVersion = lib.trivial.release;
  };

  xdg.dirs = {
    data.nix.persist = true; # REPL history
    state.nix.create = true;
    cache.nix.persist = true; # tarballs
  };
}
