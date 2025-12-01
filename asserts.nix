{ _prefix, options, config, lib, modules, extendModules, ... }@ self:

with lib;

let
  dropPrefix = drop (length _prefix);

  collectModules = lib.modules.collectModules "";
  collectedModules = (collectModules modules self).modules;

  mkRedundantAssert = loc: optValue: file: defValue:
  let
    removeAttrByPath = path: set:
      mkMerge (forEach (pushDownProperties set) (set:
        if length path == 1 then removeAttrs set path else set // {
          ${head path} = removeAttrByPath (tail path) set.${head path} or {};
        }
      ));

    systemWithoutDef = extendModules {
      modules = forEach collectedModules
        (m: if m._file != file then m else {
          disabledModules = [m];
          inherit (m) _file options;
          config = removeAttrByPath (dropPrefix loc) m.config;
        });
    };

    valueWithoutDef = getAttrFromPath (dropPrefix loc) systemWithoutDef.config;

    prettyOpt = "option `${showOption loc}' defined in `${file}'";
    prettyVal = generators.toPretty { multiline = false; } defValue;
  in
  {
    assertion = builtins.traceVerbose "Checking the ${prettyOpt}…"
      (!(builtins.tryEval (valueWithoutDef == optValue)).value);

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

    collectAsserts = v: v.assertions or
      (concatMap collectAsserts (if isAttrs v then attrValues v else v));
  in
    concatMap (opt: optionals (
      !elem (last opt.loc) [ "assertions" "warnings" "stateVersion" ] && #176295
      !hasPrefix "Alias" opt.description or "" && #355488
      hasAttrByPath (dropPrefix opt.loc) freeform.config
    ) (
      forEach (filterUserModules opt.definitionsWithLocations)
        (def: mkRedundantAssert opt.loc opt.value def.file def.value)
    ++
      optionals (opt.type.getSubModules != null) (
        collectAsserts ((opt.type.substSubModules (
          opt.type.getSubModules ++ [ subModule __curPos.file ]
        )).merge opt.loc opt.definitionsWithLocations)
      )
    ));
in

{
  options.assertions = mkOption {};
  config.assertions =
    forEach config.warnings or [] (message:
      { assertion = false; inherit message; }
    ) ++
      mkRedundantAsserts (collect isOption options);
}
