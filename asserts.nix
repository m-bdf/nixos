{ _prefix, options, config, lib, modules, extendModules, ... }@ self:

with lib;

let
  dropPrefix = drop (length _prefix);

  collectModules = lib.modules.collectModules "";
  collectedModules = (collectModules modules self).modules;

  mkRedundantAssert = loc: value: def:
  let
    removeAttrByPath = path: set:
      mkMerge (forEach (pushDownProperties set) (set:
        if length path == 1 then removeAttrs set path else set // {
          ${head path} = removeAttrByPath (tail path) set.${head path} or {};
        }
      ));

    systemWithoutDef = extendModules {
      modules = forEach collectedModules
        (m: m // optionalAttrs (m._file == def.file) {
          disabledModules = [m];
          key = "${m.key}:-${showOption loc}";
          config = removeAttrByPath (dropPrefix loc) m.config;
          imports = [];
        });
    };

    optWithoutDef = getAttrFromPath (dropPrefix loc) systemWithoutDef.options;

    prettyOpt = "option `${showOption loc}' defined in `${def.file}'";
    prettyVal = generators.toPretty { multiline = false; } def.value;
  in
  {
    assertion = builtins.traceVerbose "Checking the ${prettyOpt}…"
      optWithoutDef.isDefined ->
        !(builtins.tryEval (optWithoutDef.value == value)).value;

    message = "The ${prettyOpt} is set to the redundant value `${prettyVal}'.";
  };

  mkRedundantAsserts =
  let
    userFiles = catAttrs "_file" (take (length modules) collectedModules);
    filterUserModules = filter (m: elem m.file or m._file userFiles);

    freeform = evalModules {
      modules = [ rec {
        freeformType = with types;
          either (attrsOf freeformType) unspecified;
        config = mkMerge (catAttrs "config" collectedModules);
      }];
    };

    subModule = { moduleType, ... }@ self: {
      _module.args.modules = filterUserModules
        (collectModules moduleType.getSubModules self).modules;
    };

    collectAsserts = v: v._asserts or
      (concatMap collectAsserts (if isAttrs v then attrValues v else v));
  in
    concatMap (opt: optionals (
      !elem (last opt.loc) [ "assertions" "warnings" "stateVersion" ] && #176295
      hasAttrByPath (dropPrefix opt.loc) freeform.config
    ) (
      if opt.type.getSubModules == null then
        map (mkRedundantAssert opt.loc opt.value)
          (filterUserModules opt.definitionsWithLocations)
      else if hasPrefix "Alias" opt.description then [] #355488
      else
        collectAsserts ((opt.type.substSubModules (
          opt.type.getSubModules ++ [ subModule __curPos.file ]
        )).merge opt.loc opt.definitionsWithLocations)
    ));
in

{
  options._asserts = mkOption {
    default = mkRedundantAsserts (collect isOption options);
  };

  config = optionalAttrs (options ? assertions) {
    assertions = config._asserts ++ forEach config.warnings
      (message: { assertion = false; inherit message; });
  };
}
