{ inputs, rustPlatform, rust-bin, callPackage, runCommandLocal }:

let
  cargo-osdk = rustPlatform.buildRustPackage (final: {
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

  rustToolchain = (
    rust-bin.fromRustupToolchainFile (kernel.src + /rust-toolchain.toml)
  ).overrideAttrs (prev: { paths = prev.paths ++ [ cargo-osdk ]; });

  kernel = callPackage ./kernel.nix { inherit inputs rustToolchain; };

  installer = runCommandLocal "aster-installer" {} ''
    cp -R --no-preserve=mode ${inputs.asterinas}/distro $out

    sed -i 's|\.\./.*/|${kernel}/|' \
      $out/aster_nixos_installer/default.nix

    sed -i '/systemBuilderCommands/i \
      system.build.initialRamdisk = initramfs;
    ' $out/etc_nixos/modules/core.nix

    sed -Ei 's|=(\w+)|="\1"|
      s|extraConfig =|settings.Manager = fromTOML|
    ' $out/etc_nixos/modules/systemd.nix
  '';
in

import (installer + /aster_nixos_installer) {}
  + /etc_nixos/aster_configuration.nix
