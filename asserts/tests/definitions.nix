# Definition kinds and priorities: how `mkIf`, `mkForce`, `mkDefault`,
# `mkMerge`, priorities, `opt.apply`, `mkOptionDefault`, and types with an
# old-style (v1) `merge` function affect whether a definition is redundant.
# Where both behaviors apply, a test defines `redundant` (equal to the
# default) and `real` (a definition that changes the value).

{ lib, userModule, redundant, runAsserts }:

with lib;
with types;

{
  # `mkIf true` discharges to its content: the definition counts.
  testMkIfTrue = let
    m = userModule "mk-if-true" { config.value = mkIf true 5; };
  in
  {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "value" 5 m) ];
  };

  # `mkIf false` is not a definition at all.
  testMkIfFalse = {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
      };
      userModules = [
        (userModule "mk-if-false" { config.value = mkIf false 7; })
      ];
    };
    expected = [ ];
  };

  # A plain definition equal to the default is redundant; a different one is
  # real.
  testPlainDefinition = let
    m = userModule "plain" {
      config = {
        redundant = 5;
        real = 7;
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        redundant = mkOption { type = int; default = 5; };
        real = mkOption { type = int; default = 5; };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "redundant" 5 m) ];
  };

  # `mkForce` to the default value is redundant; to a different value it is
  # real.
  testMkForce = let
    m = userModule "mk-force" {
      config = {
        redundant = mkForce 5;
        real = mkForce 7;
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        redundant = mkOption { type = int; default = 5; };
        real = mkOption { type = int; default = 5; };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "redundant" 5 m) ];
  };

  # `mkDefault` to the default value is redundant; to a real value it is
  # not: removing the definition leaves the option without a value, which
  # fails inside `asserts.nix`'s `tryEval`.
  testMkDefault = let
    m = userModule "mk-default" {
      config = {
        redundant = mkDefault 5;
        real = mkDefault "x";
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        redundant = mkOption { type = int; default = 5; };
        real = mkOption { type = str; };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "redundant" 5 m) ];
  };

  # `mkMerge` flattens into several definitions: parts equal to the default
  # are redundant; a part that changes the merged value is not.
  testMkMerge = let
    m = userModule "mk-merge" {
      config = {
        redundant = mkMerge [ 5 5 ];
        real = mkMerge [ 5 (mkForce 7) ];
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        redundant = mkOption { type = int; default = 5; };
        real = mkOption { type = int; default = 5; };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "redundant" 5 m) ];
  };

  # A definition overridden by a higher-priority definition elsewhere is
  # *not* flagged: `opt.files` only keeps the winning definitions, so this
  # module is never among them. Locks in the behavior: no crash, no flag.
  testOverriddenByHigherPriority = {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
      };
      userModules = [
        (userModule "overridden" { config.value = 5; })
      ];
      extraModules = [ { config.value = mkForce 7; } ];
    };
    expected = [ ];
  };

  # `opt.apply` runs after the merge: a definition whose applied value
  # matches the applied default is redundant. The message shows the value the
  # module itself defines (before `apply`), not the applied option value.
  testOptApply = let
    m = userModule "opt-apply" {
      config = {
        redundant = 2;
        real = 2;
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        redundant = mkOption {
          type = int;
          default = 2;
          apply = x: x * 2;
        };
        real = mkOption {
          type = int;
          default = 4;
          apply = x: x / 2;
        };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "redundant" 2 m) ];
  };

  # Lists concatenate: a definition equal to another module's changes the
  # merged value, so it is not redundant.
  testListConcatenation = {
    expr = runAsserts {
      options = {
        values = mkOption { type = listOf str; default = [ ]; };
      };
      userModules = [
        (userModule "list-concat" { config.values = [ "a" ]; })
      ];
      extraModules = [ { config.values = [ "b" ]; } ];
    };
    expected = [ ];
  };

  # A forced definition whose removal would let a lower-priority definition
  # win is not redundant.
  testForceOverLowerPriority = {
    expr = runAsserts {
      options = {
        value = mkOption {
          type = int;
          default = 1;
        };
      };
      userModules = [
        (userModule "force-over-lower" { config.value = mkForce 5; })
      ];
      extraModules = [ { config.value = mkDefault 7; } ];
    };
    expected = [ ];
  };

  # A definition whose only priority is the option default's own
  # (`mkOptionDefault`, priority 1001) is skipped entirely: `asserts.nix`
  # cannot tell it apart from the default itself, so it is never flagged.
  # Exercises the `mkOverride opt.highestPrio {} != mkOptionDefault {}` guard.
  testMkOptionDefaultOnly = {
    expr = runAsserts {
      options = {
        value = mkOption { type = int; default = 5; };
      };
      userModules = [
        (userModule "mk-option-default" { config.value = mkOptionDefault 5; })
      ];
    };
    expected = [ ];
  };

  # A type with an old-style (v1) `merge` function (`loc: defs: ...`) and no
  # submodules (`getSubModules == null`) is checked directly like any leaf
  # option; the re-evaluation without the module uses the real merge
  # machinery. (A v1 type that also declares `getSubModules` would make
  # `asserts.nix` recurse into a non-submodule merge and crash; this locks in
  # the supported shape.)
  testV1MergeType = let
    v1Merge = mkOptionType {
      name = "int-v1";
      check = isInt;
      merge = loc: defs: (last defs).value;
    };

    m = userModule "v1-merge" { config.value = 5; };
  in
  {
    expr = runAsserts {
      options = {
        value = mkOption {
          type = v1Merge;
          default = 5;
        };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "value" 5 m) ];
  };
  # A definition that a sibling `mkDefault` would otherwise override is *not*
  # redundant, even though dropping the whole module leaves the option on its
  # `false` default. `autoHome` makes `createHome` default to `true`, so
  # removing just `createHome` (keeping the module) would activate that
  # `mkDefault`; only dropping everything the module defines hides it.
  # Exercises `mkRedundantAssert`'s per-definition (noDef) re-evaluation.
  testSiblingDefaultKeepsDefinition = {
    expr = runAsserts {
      options = {
        service = mkOption {
          type = submodule ({ config, ... }: {
            options.autoHome = mkOption { type = bool; default = false; };
            options.createHome = mkOption { type = bool; default = false; };
            config.createHome = mkIf config.autoHome (mkDefault true);
          });

          default = { };
        };
      };
      userModules = [
        (userModule "sibling-default" {
          config.service = {
            autoHome = true;
            createHome = false;
          };
        })
      ];
    };
    expected = [ ];
  };

  # The same noDef distinction for a *plain* (non-submodule) deep leaf: the
  # user module defines a parent group (`networking.firewall`) and a leaf
  # (`enable`) whose value a sibling (`allowAll`) controls via `mkIf` in another
  # module. Removing just the leaf while keeping the sibling (`removeAttrByPath`
  # recursing) flips `enable` to `true`, so the definition is *not* redundant;
  # dropping the whole parent would leave it `false`. Exercises the deep-path
  # (`length path > 1`) recursion of `removeAttrByPath`, which only happens for
  # plain nested leaf options (submodule-internal leaves go through the nested
  # `asserts` instance with a length-1 path).
  testDeepNestedDefinition = {
    expr = runAsserts {
      options = {
        networking.firewall.allowAll = mkOption { type = bool; default = false; };
        networking.firewall.enable = mkOption { type = bool; default = false; };
      };

      extraModules = [({ config, ... }: {
        config.networking.firewall.enable = mkIf config.networking.firewall.allowAll (mkDefault true);
      })];

      userModules = [
        (userModule "deep-nested" {
          config.networking.firewall = {
            allowAll = true;
            enable = false;
          };
        })
      ];
    };
    expected = [ ];
  };
}
