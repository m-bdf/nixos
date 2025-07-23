{ _prefix, options, config, lib, pkgs, modules, extendModules, ... }@ self:

with lib;

let
  getSuffix = drop (length _prefix);

  collectOptions = modules:
  let
    freeform = evalModules {
      specialArgs = self;
      modules = toList modules ++ [ rec {
        freeformType = with types;
          attrsOf (either freeformType unspecified);
      }];
    };
  in
    filter (opt: hasAttrByPath (getSuffix opt.loc) freeform.config)
      (collect isOption options);

  mkAssert = loc: file: optValue: defValue:
  let
    removeDef =
      concatMap (opt: optionals (opt.loc != loc) (
        concatMap (def: optional (def.file == file) (
          setAttrByPath (getSuffix opt.loc)
            (mkOverride opt.highestPrio def.value)
        )) opt.definitionsWithLocations
      ));

    module = if isList modules then toFunction (import file) self else modules;
    config = mkMerge (removeDef (collectOptions module));

    systemWithoutDef = extendModules {
      modules = singleton (_: module
        // (if isList modules then { key = file; } else { imports = []; })
        // (if module ? config then { inherit config; } else config)
      );
    };

    optWithoutDef = getAttrFromPath (getSuffix loc) systemWithoutDef.options;

    prettyOpt = "option `${showOption loc}' defined in `${file}'";
    prettyVal = generators.toPretty { multiline = false; } defValue;
  in
  {
    assertion = builtins.traceVerbose "Checking the ${prettyOpt}…"
      optWithoutDef.isDefined ->
        !(builtins.tryEval (optWithoutDef.value == optValue)).value;

    message = "The ${prettyOpt} is set to the redundant value `${prettyVal}'.";
  };

  wrapModules = modules:
  let
    assertsModule =
      { config, moduleType, ... }: {
        imports = modules ++ [ ./asserts.nix ];

        _module.args.modules = config._raw // {
          disabledModules =
            drop 3 (imap1 (i: m: m // {
              key = ":anon-${toString i}";
            }) moduleType.getSubModules);
        };
      };
  in
    { specialArgs, ... }: {
      freeformType = with types;
        coercedTo raw (m: {
          config = m // { _raw.config = m; };
        })
          (submoduleWith {
            inherit specialArgs;
            modules = [{
              options._raw = mkOption {
                type = deferredModule;
              };
              imports = [ assertsModule ];
            }];
          });
    };

  mkAsserts =
  let
    collectAsserts = v: v._asserts or
      (concatMap collectAsserts (if isAttrs v then attrValues v else v));
  in
    concatMap (opt:
      optionals (last opt.loc != "assertions") (
        concatMap (def:
          optional (hasPrefix (toString ./.) def.file)
            (mkAssert opt.loc def.file opt.value def.value)
        ) opt.definitionsWithLocations
      )
    ++
      optionals (opt.type.getSubModules != null) (
        collectAsserts (
          (opt.type.substSubModules [
            (wrapModules opt.type.getSubModules)
          ]).merge opt.loc opt.definitionsWithLocations
        )
      )
    );
in

{
  options._asserts = mkOption {
    default = mkAsserts (collectOptions modules);
  };

  config = optionalAttrs (options ? assertions) {
    assertions = config._asserts ++ forEach config.warnings
      (message: { assertion = false; inherit message; });
  };
}
