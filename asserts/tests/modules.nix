# User modules: how the user's own modules are discovered (path and
# attribute-set entries of `specialArgs.modules`), evaluated, attributed
# (`opt.files`), and re-evaluated without (imports, self-declared options),
# plus the `stateVersion` exemption and the `mkOptionDefault`-only guard.

{ lib, userModule, redundant, runAsserts }:

with lib;
with types;

{
  # No user modules: nothing to check, so no assertions at all.
  testNoUserModules = {
    expr = runAsserts { };
    expected = [ ];
  };

  # Each definition is attributed to the module's `_file`.
  testFileAttribution = let
    first = userModule "first-file" { config.a = 1; };
    second = userModule "second-file" { config.b = 1; };
  in
  {
    expr = runAsserts {
      options = {
        a = mkOption { type = int; default = 1; };
        b = mkOption { type = int; default = 1; };
      };
      userModules = [ first second ];
    };
    expected = [
      (redundant "a" 1 first)
      (redundant "b" 1 second)
    ];
  };

  # Definitions from modules imported by a user module are attributed to the
  # imported module's `_file`, not the user's, so they are not checked. The
  # imported module is a real file so that `asserts.nix`'s re-evaluations
  # (which re-import the user module's imports) can load it.
  testImportedDefinitionsNotChecked = {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 1; };
      };
      userModules = [
        (userModule "importer" {
          imports = [
            (toFile "imported.nix" "{ config.value = 1; }")
          ];
        })
      ];
    };
    expected = [ ];
  };

  # When a user module imports a module that *declares* options, removing the
  # user module for the re-evaluation re-declares those options twice (once
  # from the module's own `options`, which already include the imported
  # declarations, and once from re-importing the imports), so the
  # re-evaluation fails inside `asserts.nix`'s `tryEval` and the definition
  # is silently never flagged. Locks in that behavior.
  testImportsKeptInReeval = {
    expr = runAsserts {
      userModules = [
        (userModule "importer" {
          imports = [
            (toFile "helper.nix" ''
              { lib, ... }: {
                options.value = lib.mkOption { type = lib.types.int; default = 1; };
              }
            '')
          ];
          config.value = 1;
        })
      ];
    };
    expected = [ ];
  };

  # An attribute-set import, whose `_file` differs from its fallback `key`,
  # is not re-imported by the re-evaluations (the `m.key == m.file` filter
  # excludes it): its definitions are attributed to the imported module's
  # `_file`, so the importer is not flagged either.
  testAttrsetImportNotReimported = {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 1; };
      };
      userModules = [
        (userModule "importer" {
          imports = [
            { _file = "/user-modules/imported-attrset.nix"; config.value = 1; }
          ];
        })
      ];
    };
    expected = [ ];
  };

  # A path module whose function takes an argument the module system doesn't
  # pass directly: the module is evaluated by `asserts.nix` with the same
  # arguments the module system would use, so `extra` resolves from
  # `_module.args`.
  testPathModuleModuleArgs = {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
      };
      userModules = [
        (unsafeDiscardStringContext (
          toFile "path-module-args.nix" ''
            { extra, ... }: { config.value = extra; }
          ''
        ))
      ];
      extraModules = [ { _module.args.extra = 42; } ];
    };
    expected = [ ];
  };

  # A path module that uses its `extra` argument (provided via `_module.args`)
  # as a dynamic attribute name: building the config forces it, so
  # `asserts.nix` resolves the `extra` argument.
  testPathModuleArgKey = let
    m = unsafeDiscardStringContext (
      toFile "path-module-arg-key.nix" ''
        { extra, ... }:
        { config.group."''${extra}" = 1; }
      ''
    );
  in {
    expr = runAsserts {
      options = {
        group.dynamic = mkOption { type = int; default = 1; };
      };
      userModules = [ m ];
      extraModules = [ { _module.args.extra = "dynamic"; } ];
    };
    expected = [ (redundant "group.dynamic" 1 m) ];
  };

  # A user module without `_file` is attributed to `<unknown-file>`; its
  # definitions are still checked.
  testFilelessModule = {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
      };
      userModules = [ { config.value = 9; } ];
    };
    expected = [ ];
  };

  # Function modules in `specialArgs.modules` are not collected (`elem`
  # never matches a function), so their definitions are never checked —
  # even a redundant one. Attribute-set modules are still checked.
  testNonModulesIgnored = let
    m = userModule "attrset" { config.other = 5; };
  in
  {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
        other = mkOption { type = int; default = 5; };
      };
      userModules = [
        m
        ({ config, ... }: { config.value = 5; })
      ];
    };
    expected = [ (redundant "other" 5 m) ];
  };

  # Options the user never defines are never examined, even if their default
  # cannot be evaluated at all.
  testUntouchedBrokenDefault = {
    expr = runAsserts {
      options = {
        value = mkOption { type = str; };

        broken = mkOption {
          type = str;

          # A default that can't even be evaluated: the option must never be
          # touched unless the user actually defines it.
          default = { }.missing;
        };
      };
      userModules = [
        (userModule "unrelated" { config.value = "x"; })
      ];
    };
    expected = [ ];
  };

  # An option declared *and* defined by the same user module: its
  # declaration must survive disabling, so it is still checked.
  testSelfDeclaredOption = let
    m = userModule "self-declared" {
      options.enabled = mkEnableOption "something";
      config = {
        enabled = false;
        value = 1;
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 1; };
      };
      userModules = [ m ];
    };
    expected = [
      (redundant "enabled" false m)
      (redundant "value" 1 m)
    ];
  };

  # `system.stateVersion` is exempt (nixpkgs#176295).
  testStateVersionExempt = {
    expr = runAsserts {
      options = {
        system.stateVersion = mkOption { type = str; default = "24.05"; };
      };
      userModules = [
        (userModule "state-version" {
          config.system = { stateVersion = "24.05"; };
        })
      ];
    };
    expected = [ ];
  };

  # Module-level attributes (like `_module.args`) are not part of a module's
  # `config`, so they are never examined: `_module` is exempt from the
  # check.
  testModuleInternalsIgnored = {
    expr = runAsserts {
      options = {
        foo = mkOption { type = int; default = 1; };
      };
      userModules = [
        (userModule "module-internals" { _module.args.foo = 1; })
      ];
    };
    expected = [ ];
  };
}
