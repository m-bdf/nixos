{ inputs, lib, pkgs, ... }:

pkgs.rustPlatform.buildRustPackage (final: {
  pname = "rustyscript";
  version = "dev";

  src = inputs.rustyscript;
  cargoLock.lockFile = final.src + /Cargo.lock;

  RUSTY_V8_ARCHIVE =
  let
    find = name: lib.findFirst (p: p.name == name) null;

    v8Package = find "v8"
      (lib.importTOML final.cargoDeps.lockFile).package;

    rustyV8Release = find "v${v8Package.version}"
      (lib.importJSON inputs.rusty-v8-releases);

    rustyV8Asset =
      find "librusty_v8_${final.cargoBuildType}_${
        pkgs.stdenv.hostPlatform.rust.cargoShortTarget
      }.a.gz" rustyV8Release.assets;
  in
    pkgs.fetchurl {
      url = rustyV8Asset.browser_download_url;
      hash = rustyV8Asset.digest;
    };

  doCheck = false;
})
