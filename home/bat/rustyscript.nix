{ inputs, lib, craneLib, fetchurl, stdenv }:

craneLib.buildPackage rec {
  pname = "rustyscript";
  version = "git";
  src = inputs.rustyscript;

  strictDeps = true;
  cargoExtraArgs = "--no-default-features";

  RUSTY_V8_ARCHIVE =
  let
    find = name: lib.findFirst (p: p.name == name) null;

    v8Package = find "v8"
      (lib.importTOML (src + /Cargo.lock)).package;

    rustyV8Release = find "v${v8Package.version}"
      (lib.importJSON inputs.rusty-v8-releases);

    rustyV8Asset =
      find "librusty_v8_release_${
        stdenv.hostPlatform.rust.cargoShortTarget
      }.a.gz" rustyV8Release.assets;
  in
    fetchurl {
      url = rustyV8Asset.browser_download_url;
      hash = rustyV8Asset.digest;
      passthru = rustyV8Asset;
    };

  doCheck = false;
  doInstallCargoArtifacts = true;
}
