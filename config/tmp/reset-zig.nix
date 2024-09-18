final: prev:

with prev.lib;

let
  overridenCC = {
    bintoolsLLVM = final.stdenv.cc.override {
      inherit (final.llvmPackages) bintools;
    };

    bintools = final.stdenv.cc.override {
      inherit (final) bintools;
    };

    bintoolsBuild = final.stdenv.cc.override {
      inherit (final.buildPackages) bintools;
    };

    cc = final.gcc;
    ccBuild = final.buildPackages.gcc;
    ccBuildBuild = final.buildPackages.buildPackages.gcc;
  };

  overrideCC = override: name: prev.${name}.override {
    stdenv = final.overrideCC final.stdenv overridenCC.${override};
  };
in

concatMapAttrs (override: names: genAttrs names (overrideCC override))
{
  bintoolsLLVM = [
    "file"
    "icu"
    "lowdown"
  ];

  bintools = [
    "boehmgc"
    "cracklib"
    "krb5"
    "libbsd"
    "libedit"
    "libgcrypt"
    "libpipeline"
    "libssh2"
    "ncurses"
    "nghttp2"
    "pkg-config-unwrapped"
    "python3"
  ];

  bintoolsBuild = [
    "gettext"
    "gmp"
    "perl"
  ];

  cc = [
    "keyutils"
    "unzip"
  ];

  # ccBuild = [
  #   # "gnum4"
  #   # "libpipeline"
  # ];
}

//

{
  perlPackages = prev.perlPackages.overrideScope (final: prev: {
    perl = overrideCC "cc" "perl";
  });

  expect = prev.expect.override {
    buildPackages.tcl = overrideCC "cc" "tcl";
  };

  linuxHeaders = prev.linuxHeaders.override {
    # buildPackages.stdenv.cc = final.gcc;
    buildPackages.stdenv.cc = overridenCC.ccBuildBuild;
  };

  kexec-tools = prev.linuxHeaders.override {
    buildPackages.stdenv.cc = overridenCC.bintools;
  };
}
