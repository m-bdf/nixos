{ inputs, pkgs, ... }:

let
  cargo-osdk = pkgs.rustPlatform.buildRustPackage (final: {
    pname = "cargo-osdk";
    version = "git";

    src = inputs.asterinas;
    sourceRoot = "source/osdk";
    cargoLock.lockFile = final.src + /osdk/Cargo.lock;

    patchPhase = ''
      sed -i '/build-std/d' src/commands/{util.rs,build/bin.rs}
    '';

    OSDK_LOCAL_DEV = true;
    doCheck = false;
  });

  rustToolchain = ((inputs.rust-overlay.lib.mkRustBin {} pkgs)
    .fromRustupToolchainFile (cargo-osdk.src + /rust-toolchain.toml)
  ).overrideAttrs (prev: { paths = prev.paths ++ [ cargo-osdk ]; });

  rustPlatform = pkgs.makeRustPlatform
    { rustc = rustToolchain; cargo = rustToolchain; };
in

{
  aster_nixos.kernel = pkgs.callPackage ./kernel.nix
    { inherit inputs rustPlatform; } + /aster-kernel-osdk-bin;
}
