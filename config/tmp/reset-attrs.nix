final: prev:

with prev.lib;

let
  overrideAttrs = attrs: pkg:
    if isFunction pkg then args: overrideAttrs attrs (pkg args)
    else pkg.overrideAttrs or (_: pkg) (genAttrs (toList attrs)
      (attr: if attr == "configurePlatforms" then [] else false));

  mkOverrides = attrs: names: prev:
    genAttrs (toList names) (name: overrideAttrs attrs prev.${name});

  mkCrossOverrides = prev: overrides:
    zipAttrsWith (name: attrs: overrideAttrs attrs prev.${name})
      (mapAttrsToList (attr: names: genAttrs names (name: attr)) overrides);
in

mkCrossOverrides prev
{
  doCheck = [
    "appstream"
    "audit"
    "aws-c-auth"
    "aws-c-http"
    "aws-c-io"
    "aws-c-s3"
    "aws-crt-cpp"
    "colord"
    "cracklib"
  #   "cups-browsed"
    "doxygen"
    "dpkg"
    "efivar"
    "eigen"
    "espeak"
    "fftw"
    "fontforge"
    "fprintd"
    "geocode-glib"
    "getopt"
    "gettext"
    "giflib"
    "gjs"
    "glib"
    "gnome-bluetooth_1_0"
    "gnome-settings-daemon"
    "gnupg"
    "gperftools"
    "gtk-layer-shell"
  #   "gtkmm4"
    "gupnp-igd"
    "hfst-ospell"
    "hspell"
    "hyphen"
    "iio-sensor-proxy"
    "iptables"
  #   "jsoncpp"
  #   "libadwaita"
    "libbytesize"
  #   "libcacard"
    "libcap"
  #   "libcupsfilters"
  #   "libei"
    "libgweather"
    "libhandy"
    "libical"
    "libliftoff"
    "libndctl"
    "libnl"
    "librdf_raptor2"
    "librist"
    "librsync"
    "libssh2"
    "libstartup_notification"
    "libtpms"
    "libvoikko"
    "libxmlxx3"
    "lilv"
    "linux-firmware"
    "linuxHeaders"
    "logrotate"
    "mailcap"
    "modemmanager"
    "neon"
    "openconnect"
    "openssl"
    "ostree"
    "pkgconf-unwrapped"
    "python311"
    "python312"
    "python3Minimal"
    "rdfind"
    "river"
    "rust-cbindgen"
    "s2n-tls"
    "shared-mime-info"
  #   "spice"
    "spidermonkey_128"
    "strace"
    "supercollider"
    "tinyxxd"
  #   "vte"
    "wireplumber"
    "xdg-utils"
    "xmlstarlet"
  #   "xwayland"
  #   "yasm"
    "zvbi"
  ];

  doInstallCheck = [
    "bash-completion"
    # "kitty"
    "postgresql"
    "sox"
  ];

  strictDeps = [
    "blueprint-compiler"
    # "cups-browsed"
    # "cups-filters"
    "docbook2x"
    "fontforge"
    "gtk2"
    # "libcupsfilters"
    # "libppd"
    "libxklavier"
    "parallel" #?
    "poppler"
    # "poppler_utils"
    "psqlodbc"
    "river"
    "swig"
    "uwsm"
    "waybar"
    "wayland-protocols"
    "xmlto"
    "yodl"
  ];

  __structuredAttrs = [
    "addDriverRunpath"
    "bundler"
    "colord"
    "dbus-broker"
    "fftw"
    "fprintd"
    "fwupd"
    # "gi-docgen"
    "glibcLocalesUtf8"
    # "go_1_23"
    # "go-md2man"
    "hspell"
    "kbd"
    "kmscon"
    "krb5"
    "libbpf"
    # "libtirpc"
    "libxmlb"
    "linux_zen"
    "lklWithFirewall"
    # "makeModulesClosure"
    "mdbook-linkcheck"
    "openldap"
    "pkg-config"
    "pkgconf"
    "power-profiles-daemon"
    "python27"
    "removeReferencesTo"
    "ronn"
    "rust-bindgen"
    # "rutabaga_gfx"
    "substitute"
    "substituteAll"
    # "systemd"
    "unbound"
    "uwsm"
    "x265"
  ];

  enableParallelBuilding = [
    "linux-firmware"
  ];

  configurePlatforms = [
    "alsa-firmware"
  ];
}

//

{
  # runCommand = name: args: overrideAttrs
  #   (optional (args ? passAsFile) "__structuredAttrs")
  #   (prev.runCommand name args);

  # runCommandLocal = name: args: overrideAttrs
  #   (optional (args ? passAsFile) "__structuredAttrs")
  #   (prev.runCommandLocal name args);

  # buildLinux = args: (prev.buildLinux args).override
  #   (prev: optionalAttrs (prev ? stdenv) {
  #     stdenv = final.addAttrsToDerivation
  #       { __structuredAttrs = false; } prev.stdenv;
  #   });

  nixVersions = prev.nixVersions.extend
    (_: mkOverrides [ "doCheck" "__structuredAttrs" ] "latest");

  llvmPackages = prev.llvmPackages // {
    libclc = overrideAttrs [ "doCheck" "__structuredAttrs" ] prev.llvmPackages.libclc;
  };

  xorg = prev.xorg.overrideScope (_: mkOverrides "doCheck" "xorgproto");

  qt5 = prev.qt5.overrideScope
    (_: prev: { qttranslations = null; } //
      mkOverrides [ "strictDeps" "__structuredAttrs" "configurePlatforms" ] "qtbase" prev //
      mkOverrides "strictDeps" [ "qtwebchannel" "qtwebengine" "qtwebsockets" ] prev
    );

  libsForQt5 = prev.libsForQt5.overrideScope
    (_: mkOverrides [ "strictDeps" "__structuredAttrs" ] "qwt");

  qt6 = prev.qt6.overrideScope (_: _: { qttranslations = null; });

  mate = prev.mate.overrideScope (_: prev:
    mkOverrides "strictDeps" [ "marco" "mate-panel" ] prev //
    mkOverrides "doCheck" "libmateweather" prev
  );

  # resholve = prev.resholve.override (prev: {
  #   resholve-utils = prev.resholve-utils.override
  #     (mkOverrides "__structuredAttrs" "resholve");
  # });

  rustPackages = prev.rustPackages.overrideScope
    (final: prev: { buildRustPackages = final; } //
      mkOverrides [ "doCheck" "__structuredAttrs" ] "rustc-unwrapped" prev //
      mkOverrides "__structuredAttrs" [ "rustfmt" "clippy" ] prev
    );

  pythonPackagesExtensions = [
    (_: prev:
      mkCrossOverrides prev
      {
        doInstallCheck = [
          # "afdko"
          # "hatch-fancy-pypi-readme"
          # "mypy"
          # "psautohint"
          # "psutil"
          # "pycparser"
          # "python-dbusmock"
          # "pytz"
          # "requests"
          # "scikit-build"
          # "sphinx"
          # "time-machine"
        ];

        __structuredAttrs = [
          # "matplotlib"
          # "pkgconfig"
          # "pystemmer"
        ];
      }
    )
  ];

  haskell = prev.haskell // {
    packageOverrides = _: prev:
      mkCrossOverrides prev
      {
        doCheck = [
          "base-compat-batteries"
          "blaze-builder"
          "citeproc"
          "doclayout"
          "doctest"
          "foundation"
          "haddock-library"
          "hermes-json"
          "http-types"
          "memory"
          "quickcheck-classes"
          "retry"
          "typst"
          "unicode-collation"
          "unordered-containers"
          "yaml"
        ];

        strictDeps = [
          "auto-update"
          "hspec-wai"
          "http-date"
          "http-types"
          # "JuicyPixels"
          # "streaming-commons"
          "unliftio"
          "word8"
          "yaml"
        ];

        __structuredAttrs = [
          "basement"
          "ghc"
          "hedgehog"
          "lpeg"
          "lua"
          "pcre-light"
          "prettyprinter"
          "prettyprinter-ansi-terminal"
          "prettyprinter-compat-ansi-wl-pprint"
          "zlib"
        ];
      };
  };

  defaultGemConfig = genAttrs
    [
      "addressable"
      "afm"
      "Ascii85"
      "asciidoctor"
      "asciidoctor-pdf"
      "coderay"
      "concurrent-ruby"
      "css_parser"
      "hashery"
      "kramdown"
      "kramdown-parser-gfm"
      "matrix"
      "mini_portile2"
      "mustache"
      "nokogiri"
      "pdf-core"
      "pdf-reader"
      "polyglot"
      "prawn"
      "prawn-icon"
      "prawn-svg"
      "prawn-table"
      "prawn-templates"
      "public_suffix"
      "pygments.rb"
      "racc"
      "rexml"
      "ronn-ng"
      "rouge"
      "ruby-rc4"
      "tilt"
      "treetop"
      "ttfunk"
      "zookeeper"
    ]
      (name: value: { __structuredAttrs = false; });

  # beamPackages =
  #   (prev.beamPackages.override (prev: {
  #     erlang = prev.erlang.override (prev: {
  #       ex_doc = prev.ex_doc.override (prev: {
  #         erlang = overrideAttrs "doCheck" prev.erlang;
  #       });
  #     });
  #   })).extend (_: prev:
  #     mkOverrides [ "doCheck" "strictDeps" ] "elixir" prev //
  #     mkOverrides "strictDeps" [ "hex" "rebar3" ] prev
  #   );
}
