# Submodule recursion: options whose type embeds submodules (`submodule`,
# `attrsOf`, `listOf`, ...) are checked recursively at the right depth.
# `asserts.nix` re-includes itself in the submodule evaluations, so the
# sub-options are checked by a nested instance. Sub-options that can't be
# evaluated (throwing defaults) are skipped, not crashed on.

{ lib, userModule, redundant, runAsserts }:

with lib;
with types;

{
  # Options inside `attrsOf submodule`: a redundant sub-option is flagged;
  # an attribute with no sub-option definitions is not checked at all.
  testAttrsOfSubmodule = let
    m = userModule "attrs-of-submodule" {
      config.services = {
        daemon = { script = "run"; enable = false; };
        other = { enable = true; };
        empty = { };
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        services = mkOption {
          type = attrsOf (submodule {
            options.script = mkOption { type = str; default = ""; };
            options.enable = mkOption { type = bool; default = false; };
          });

          default = { };
        };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "services.daemon.enable" false m) ];
  };

  # Options inside a plain `submodule` option.
  testPlainSubmodule = let
    m = userModule "plain-submodule" {
      config.settings = {
        a = 5;
        b = false;
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        settings = mkOption {
          type = submodule {
            options.a = mkOption { type = int; default = 0; };
            options.b = mkOption { type = bool; default = false; };
          };

          default = { };
        };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "settings.b" false m) ];
  };

  # Options inside `attrsOf (attrsOf submodule)` options.
  testNestedAttrsOfSubmodule = let
    m = userModule "nested-attrs-of-submodule" {
      config.deeper = {
        g1 = { h = { x = 42; }; };
        g2 = { h = { x = 0; }; };
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        deeper = mkOption {
          type = attrsOf (attrsOf (submodule {
            options.x = mkOption { type = int; default = 0; };
          }));

          default = { };
        };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "deeper.g2.h.x" 0 m) ];
  };

  # Options inside `listOf submodule` *are* checked. Each element becomes its
  # own submodule evaluation, so the sub-options' locs run through the list —
  # `entries.[definition 1-entry 1].x` — and the redundant sub-option of the
  # first element is flagged. Non-redundant elements and options without a
  # value are not.
  testListOfSubmodule = let
    m = userModule "list-of-submodule" {
      config.entries = [
        { x = 0; y = "a"; }
        { x = 1; y = "b"; }
      ];
    };
  in
  {
    expr = runAsserts {
      options = {
        entries = mkOption {
          type = listOf (submodule {
            options.x = mkOption { type = int; default = 0; };
            options.y = mkOption { type = str; };
          });

          default = [ ];
        };
      };
      userModules = [ m ];
    };
    expected = [
      (redundant "entries.\"[definition 1-entry 1]\".x" 0 m)
    ];
  };

  # `attrsOf (listOf submodule)`: the list elements inside each attribute are
  # checked, with the same list-shaped locs.
  testAttrsOfListOfSubmodule = let
    m = userModule "attrs-of-list-of-submodule" {
      config.groups = {
        a = [ { q = 0; } { q = 1; } ];
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        groups = mkOption {
          type = attrsOf (listOf (submodule {
            options.q = mkOption { type = int; default = 0; };
          }));

          default = { };
        };
      };
      userModules = [ m ];
    };
    expected = [
      (redundant "groups.a.\"[definition 1-entry 1]\".q" 0 m)
    ];
  };

  # `listOf (attrsOf submodule)`: the list elements are checked, with the
  # same list-shaped locs.
  testListOfAttrsOfSubmodule = let
    m = userModule "list-of-attrs-of-submodule" {
      config.teams = [
        { a = { x = 0; }; }
      ];
    };
  in
  {
    expr = runAsserts {
      options = {
        teams = mkOption {
          type = listOf (attrsOf (submodule {
            options.x = mkOption { type = int; default = 0; };
          }));

          default = [ ];
        };
      };
      userModules = [ m ];
    };
    expected = [
      (redundant "teams.\"[definition 1-entry 1]\".a.x" 0 m)
    ];
  };

  # Submodules nested inside submodules.
  testNestedSubmodules = let
    m = userModule "nested-submodules" {
      config.outer = {
        inner = { z = 0; };
        inner2 = { z = 7; };
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        outer = mkOption {
          type = submodule {
            options.inner = mkOption {
              type = submodule {
                options.z = mkOption { type = int; default = 0; };
              };

              default = { };
            };

            options.inner2 = mkOption {
              type = submodule {
                options.z = mkOption { type = int; default = 0; };
              };

              default = { };
            };
          };

          default = { };
        };
      };
      userModules = [ m ];
    };
    expected = [ (redundant "outer.inner.z" 0 m) ];
  };

  # A user module that declares a submodule-typed option *and* defines a
  # redundant value inside it: the sub-option is checked inside the
  # submodule evaluation (where the definition is one of the user modules),
  # so it is flagged like any other redundant definition.
  testSelfDeclaredSubmodule = let
    m = userModule "self-declared-submodule" {
      options.setting = mkOption {
        type = submodule {
          options.x = mkOption { type = int; default = 0; };
        };
        default = { };
      };
      config.setting.x = 0;
    };
  in
  {
    expr = runAsserts {
      userModules = [ m ];
    };
    expected = [ (redundant "setting.x" 0 m) ];
  };

  # `visible = "shallow"`: leaf options are still checked directly; submodule
  # options are checked as a whole, never recursed into. The message shows
  # the module's own definition — without the submodule's defaults.
  testShallowVisible = let
    m = userModule "shallow" {
      config = {
        shallowLeaf = 1;
        shallowSub = { a = 0; };
      };
    };
  in
  {
    expr = runAsserts {
      options = {
        shallowLeaf = mkOption {
          type = int;
          default = 1;
          visible = "shallow";
        };
        shallowSub = mkOption {
          type = submodule {
            options.a = mkOption { type = int; default = 0; };
            options.b = mkOption { type = bool; default = false; };
          };

          visible = "shallow";
          default = { };
        };
      };
      userModules = [ m ];
    };
    expected = [
      (redundant "shallowLeaf" 1 m)
      (redundant "shallowSub" { a = 0; } m)
    ];
  };

  # A submodule with an option that has no value (no default, no
  # `emptyValue`) must not crash the check when only a sibling option is
  # defined.
  testOptionWithoutValue = {
    expr = runAsserts {
      options = {
        volume = mkOption {
          type = attrsOf (submodule {
            options.path = mkOption { type = path; };
            options.readonly = mkOption { type = bool; default = false; };
          });

          default = { };
        };
      };
      userModules = [
        (userModule "option-without-value" {
          config.volume = { nix = { readonly = true; }; };
        })
      ];
    };
    expected = [ ];
  };

  # A sub-option whose default throws must not crash the check on another
  # sub-option: the throwing default is only forced by the comparison, which
  # is guarded by `tryEval`.
  testThrowingSubmoduleDefault = {
    expr = runAsserts {
      options = {
        service = mkOption {
          type = submodule {
            options.script = mkOption {
              type = str;
              default = "run";
            };

            options.enable = mkOption {
              type = bool;
              default = throw "unsupported service";
            };
          };

          default = { };
        };
      };
      userModules = [
        (userModule "throwing-default" {
          config.service = {
            enable = false;
          };
        })
      ];
    };
    expected = [ ];
  };

  # A user module that declares a submodule-typed option whose submodule
  # itself defines a config value not declared as a sub-option (like
  # `home/persist.nix`'s `config.enable = mkIf config.persist false`). The
  # definition is matched by the option's other declaration, so the
  # configuration is valid — but the user module must only be read
  # structurally: evaluating it standalone has no `enable` option to match
  # against and crashes. Locks in: no crash.
  testSubmoduleInternalConfig = {
    expr = runAsserts {
      options = {
        service = mkOption {
          type = attrsOf (submodule {
            options.enable = mkOption { type = bool; default = false; };
          });
        };
      };
      userModules = [
        (userModule "submodule-internal-config" {
          options.service = mkOption {
            type = attrsOf (submodule ({ config, ... }: {
              options.persist = mkOption { type = bool; default = false; };
              config.enable = mkIf config.persist false;
            }));
          };
          config.service.daemon.persist = true;
        })
      ];
    };
    expected = [ ];
  };
}
