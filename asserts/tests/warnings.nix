# Warnings: `config.warnings` entries become failing assertions, verbatim.
# The `warnings` option itself is checked like any other (see
# `testEmptyWarnings`), and `config.assertions` is exempt from the check (see
# `testUserAssertions`).

{ lib, userModule, redundant, runAsserts }:

with lib;
with types;

{
  # Warnings become failing assertions, verbatim.
  testWarnings = {
    expr = runAsserts {
      warnings = [ "a warning" "another warning" ];
    };
    expected = [ "a warning" "another warning" ];
  };

  # Warnings and redundant definitions coexist.
  testWarningsAndRedundant = let
    m = userModule "warnings-redundant" {
      config = {
        value = 5;
        other = "x";
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
        other = mkOption { type = str; };
      };
      userModules = [ m ];
      warnings = [ "warn" ];
    };
    expected = [ (redundant "value" 5 m) "warn" ];
  };

  # The `warnings` option itself is checked like any other: defining it to
  # its default produces no warnings (so no failing assertions), but the
  # definition is still redundant. The message shows the value the module
  # itself defines (`[ ]`), not the merged value.
  testEmptyWarnings = let
    m = userModule "empty-warnings" { config.warnings = [ ]; };
  in
  {
    expr = runAsserts {
      userModules = [ m ];
      warnings = [ "warn" ];
    };
    expected = [ (redundant "warnings" [ ] m) "warn" ];
  };

  # `config.assertions` is exempt from the redundancy check: user-defined
  # assertions are merged into the module system's assertion list like any
  # other, but the `assertions` option is never examined.
  testUserAssertions = {
    expr = runAsserts {
      userModules = [
        (userModule "user-assertions" {
          config.assertions = [
            {
              assertion = true;
              message = "user assertion";
            }
          ];
        })
      ];
    };
    expected = [ ];
  };
}
