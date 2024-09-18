lib:

let
  overrideAttr = attr: pkg:
    if pkg ? overrideAttrs then pkg.overrideAttrs { ${attr} = false; } else
    if pkg ? __functor then args: overrideAttr attr (pkg args) else null;

  overrideAttrs = attr: names: prev:
    lib.genAttrs (lib.toList names) (name: overrideAttr attr prev.${name});
in

lib.mapAttrsToList (attr: names: final: overrideAttrs attr names)
{
  doCheck = [
    "acl"
    "attr"
    "audit"
    "aws-c-auth"
    "aws-c-http"
    "aws-c-io"
    "aws-c-s3"
    "aws-crt-cpp"
    "cracklib"
    "doxygen"
    "fontforge"
    "gcc-unwrapped"
    "getopt"
    "gettext"
    "giflib"
    "glib"
    "gnupg"
    "gperf"
    "gzip"
    "hiredis"
    "iptables"
    "libcap"
    "libgpg-error"
    "libidn2"
    "libpng"
    "libssh2"
    "libtpms"
    "linuxHeaders"
    "mailcap"
    "openssl"
    "pcre2"
    "python312"
    "python3Minimal"
    "s2n-tls"
    "tinyxxd"
    "yasm"
  ];

  doInstallCheck = [
    "findutils"
  ];

  strictDeps = [
    "docbook2x"
    "fontforge"
    "swig"
    "xmlto"
  ];

  __structuredAttrs = [
    "buildEnv"
    "buildRubyGem"
    "glibc"
    "glibcLocales"
    "glibcLocalesUtf8"
    "hiredis"
    "kbd"
    "krb5"
    "libbpf"
    "pkg-config"
    "removeReferencesTo"
    "substituteAll"
    "unbound"
  ];
}

++

lib.singleton (final: prev:
{
  stdenv = prev.stdenv.override (prev: {
    cc = if ! prev.cc.cc or {} ? overrideAttrs
      then prev.cc else overrideAttr "__structuredAttrs"
        (prev.cc.override (overrideAttrs "doCheck" "cc"));
  });

  stdenvNoLibc = prev.stdenvNoLibc.override (prev: {
    cc = prev.cc.override (overrideAttrs "doCheck" "cc");
  });

  rustc = prev.rustc.override (prev: {
    rustc-unwrapped = overrideAttr "__structuredAttrs"
      (overrideAttr "doCheck" prev.rustc-unwrapped);
  });

  cargo = prev.cargo.override { inherit (final) rustc; };
  rustPlatform = final.makeRustPlatform { inherit (final) rustc cargo; };

  pythonPackagesExtensions = [
    (final: overrideAttrs "__structuredAttrs" "buildPythonPackage")
    (final: overrideAttrs "__structuredAttrs" "buildPythonApplication")
  ];

  perlPackages = prev.perlPackages.overrideScope
    (final: overrideAttrs "doCheck" "XMLParser");

  xorg = prev.xorg.overrideScope
    (final: overrideAttrs "doCheck" "xorgproto");
})
