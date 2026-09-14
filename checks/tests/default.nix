{ futility ? ../futility.nix, lib }:

with lib;

let
  userModule = name: m: {
    _file = "/user-modules/${name}.nix";
    key = "/user-modules/${name}.nix";
  } // m;

  redundant = loc: value: file:
    "The option `${loc}' is defined in `${
      if isAttrs file then file._file else toString file
    }' to the redundant value `${
      generators.toPretty { multiline = false; } value
    }'.";

  runAsserts = {
    options ? {},
    userModules ? [],
    extraModules ? [],
    warnings ? [],
  }:
    let
      warningsModule =
        optional (warnings != []) {
          options.warnings = with types;
            mkOption { type = listOf str; };
          config = { inherit warnings; };
        };

      eval = evalModules {
        specialArgs.modules = userModules;

        modules = [{ inherit options; }]
          ++ userModules ++ extraModules
          ++ warningsModule ++ [ futility ];
      };
    in
      sort (a: b: a < b) (concatMap (a:
        optional (!a.assertion) a.message
      ) eval.config.assertions);

  tests = foldlAttrs (acc: n: _: acc // import ./${n} {
    inherit lib userModule redundant runAsserts;
  }) {} (removeAttrs (readDir ./.) [ "default.nix" ]);
in

debug.throwTestFailures {
  failures = debug.runTests tests;
}
