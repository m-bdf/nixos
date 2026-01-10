{ inputs, lib, pkgs, ... }:

let
  addFromSource = paths: src:
    lib.cleanSourceWith {
      src = pkgs.runCommandLocal "source" {
        paths = map (d: "${inputs.asterinas}/${d}") paths;
      } ''
        cp -R ${src} $out
        chmod +w $out $out/*
        cp -R $paths $out
      '';
    };

  inherit (import (inputs.asterinas + /test/nix) {}) initramfs-image;

  toolchain = pkgs.rust-bin.fromRustupToolchainFile
    (inputs.asterinas + /rust-toolchain.toml);
  rustPlatform = pkgs.makeRustPlatform
    { rustc = toolchain; cargo = toolchain; };

  cargo-osdk = rustPlatform.buildRustPackage (final: {
    pname = "cargo-osdk";
    version = "git";

    src = addFromSource [ "Cargo.*" "osdk" "ostd" ] pkgs.emptyDirectory;

    sourceRoot = "${final.src.name}/osdk";
    cargoLock.lockFile = final.src + /osdk/Cargo.lock;

    OSDK_LOCAL_DEV = true;
    doCheck = false;
  });

  aster-kernel = rustPlatform.buildRustPackage (final: rec {
    pname = "aster-kernel";
    version = "git";

    src = addFromSource [ "*.toml" "kernel" ] cargo-osdk.src;

    patchPhase = ''
      v=' *= *"[^"]+"'
      sed -Ei $(find .. -name Cargo.toml) \
        -e "s/git$v, rev$v, (version$v)/\1/" \
        -e "s/git$v(, ...$v)?/version = \"*\"/" \
    '';

    cargoLock = {
      lockFile = final.src + /Cargo.lock;
      allowBuiltinFetchGit = true;
    };

    cargoDeps = pkgs.symlinkJoin {
      inherit (cargo-osdk.cargoDeps) name;
      paths = [
        (rustPlatform.importCargoLock cargoLock)
        (rustPlatform.importCargoLock {
          lockFile = toolchain + /lib/rustlib/src/rust/library/Cargo.lock;
        })
      ];
    };

    nativeBuildInputs = with pkgs; [ cargo-osdk grub2 xorriso ];
    VDSO_LIBRARY_DIR = inputs.linux-vdso;

    buildPhase = ''
      cargo osdk build --release \
        --grub-boot-protocol=linux \
        --initramfs=${initramfs-image}
    '';

    auditable = false;
    doCheck = false;

    installPhase = ''
      mkdir $out
      cp -R --parents target/osdk $out
    '';
  });
in

import (
  addFromSource [ "distro" ] aster-kernel
    + /distro/aster_nixos_installer
) {}
  + /etc_nixos/aster_configuration.nix
