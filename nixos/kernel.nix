{ inputs, lib, ... }:

let
  pkgs = import inputs.nixpkgs {
    overlays = [ inputs.rust-overlay.overlays.default ];
  };

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

  workspace = rustPlatform.buildRustPackage (final: rec {
    pname = "asterinas";
    version = "git";

    src = addFromSource [ "*.toml" "tools" "kernel" ] cargo-osdk.src;

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

    nativeBuildInputs = [ cargo-osdk ];
    VDSO_LIBRARY_DIR = inputs.linux-vdso;

    buildPhase = ''
      cargo osdk build --release \
        --boot-method=qemu-direct \
        --initramfs=${initramfs-image}
    '';

    auditable = false;
    doCheck = false;

    installPhase = ''
      cp -R . $out
      mkdir -p $out/target/osdk/iso_root/boot
      ln -s $out/target/osdk/aster-nix-osdk-bin.qemu_elf \
        $out/target/osdk/iso_root/boot/aster-nix-osdk-bin
    '';
  });

  installer = (import
    (addFromSource [ "distro" ] workspace +
      /distro/aster_nixos_installer) {}
  ).overrideAttrs (prev: {
    buildCommand = prev.buildCommand + ''
      chmod +w $out/etc_nixos/modules

      sed -i 's|config.nixpkgs.overlays =|& \
        let pkgs = import ${
          toString initramfs-image.stdenv.setup
        }/../../../.. {}; \
        in map (o: final: prev: o final pkgs) \
      |' $out/etc_nixos/aster_configuration.nix

      sed -i '/systemd.extraConfig/,+3d
        s|aster_systemd|& // { withNspawn = false; }|
      ' $out/etc_nixos/modules/systemd.nix
    '';
  });
in

{
  imports = [
    (installer + /etc_nixos/aster_configuration.nix)
  ];
}
