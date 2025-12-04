{ _prefix, options, config, lib, modules, moduleType, extendModules, ... }@ self:

with lib;

let
  dropPrefix = drop (length _prefix);

  evalFreeform = module:
    evalModules {
      specialArgs = self;
      modules = [ module rec {
        freeformType = with types;
          either (attrsOf freeformType) unspecified;
      }];
    };

  collectModules =
    zipListsWith (meta: module:
      optional (elem module modules) {
        inherit (meta) key file;
        inherit (evalFreeform module) options config;
      } ++
        collectModules meta.imports module.imports or []
    );

  collectedModules = flatten
    (collectModules (extendModules {}).graph moduleType.getSubModules);

  mkRedundantAssert = opt: def:
  let
    removeAttrByPath = path: set:
      if length path == 1 then removeAttrs set path else set // {
        ${head path} = removeAttrByPath (tail path) set.${head path} or {};
      };

    noDefSystem = extendModules {
      modules = [{
        disabledModules = [def];
        options = removeAttrs def.options [ "_module" ];
        config = removeAttrByPath (dropPrefix opt.loc) def.config;
      }];
    };

    noDefVal = getAttrFromPath (dropPrefix opt.loc) noDefSystem.config;
    onlyDefVal = getAttrFromPath (dropPrefix opt.loc) def.config;

    prettyOpt = "option `${showOption opt.loc}' defined in `${def.file}'";
    prettyVal = generators.toPretty { multiline = false; } onlyDefVal;
  in
  {
    assertion = builtins.traceVerbose "Checking the ${prettyOpt}…"
      (!(builtins.tryEval (noDefVal == opt.value)).value);

    message = "The ${prettyOpt} is set to the redundant value `${prettyVal}'.";
  };

  mkRedundantAsserts = opt:
  let
    subModule = file: { moduleType, ... }: {
      _module.args.modules = filter (m: m._file or m == file)
        (subtractLists opt.type.getSubModules moduleType.getSubModules);
    };

    collectAsserts = v: v.assertions or
      (forEach (if isAttrs v then attrValues v else v) collectAsserts);
  in
    forEach collectedModules (m: optionals (
      !elem (last opt.loc) [ "assertions" "warnings" "stateVersion" ] && #176295
      !hasPrefix "Alias" opt.description or "" && #355488
      hasAttrByPath (dropPrefix opt.loc) m.config &&
      elem m.file opt.files
    ) (
      if opt.type.getSubModules != null then
        collectAsserts ((opt.type.substSubModules (
          opt.type.getSubModules ++ [ (subModule m.file) __curPos.file ]
        )).merge opt.loc opt.definitionsWithLocations)
      else
        [ (mkRedundantAssert opt m) ]
    ));
in

{
  options.assertions = mkOption {};
  config.assertions =
    forEach config.warnings or []
      (message: { assertion = false; inherit message; }) ++
    flatten (forEach (collect isOption options) mkRedundantAsserts);
}
