{ _prefix, options, config, lib, modules, moduleType, extendModules, ... }@ args:

with lib;

let
  dropPrefix = drop (length _prefix);

  disabledModules = genAttrs' collectedModules (m:
    nameValuePair m.key (extendModules {
      modules = [{
        disabledModules = [m];
        options = removeAttrs m.options [ "_module" ];
        inherit (m) imports;
      }];
    }));

  mkRedundantAssert = opt: def:
  let
    removeAttrByPath = path: set:
      if length path == 1 then removeAttrs set path else set // {
        ${head path} = removeAttrByPath (tail path) set.${head path} or {};
      };

    noDef = disabledModules.${def.key}.extendModules {
      modules = [{
        config = removeAttrByPath (dropPrefix opt.loc) def.config;
      }];
    };

    getVal = m: getAttrFromPath (dropPrefix opt.loc) m.config;
    prettyVal = generators.toPretty { multiline = false; } (getVal def);
  in
  {
    assertion = !(builtins.tryEval (getVal disabledModules.${def.key} == opt.value && getVal noDef == opt.value)).value;
    message = "The option `${showOption opt.loc}' is defined in `${def.file}' to the redundant value `${prettyVal}'.";
  };

  collectedModules =
  let
    evalFreeform = module:
      evalModules {
        specialArgs = args;
        modules = [ module rec {
          freeformType = with types;
            either (attrsOf freeformType) unspecified;
        }];
      };

    collectModules = zipListsWith (meta: module:
      optional (elem module modules) {
        inherit (meta) key file;
        inherit (evalFreeform module) options config;
        imports = catAttrs "file"
          (filter (m: m.key == m.file) meta.imports);
      } ++
        collectModules meta.imports module.imports or []
    );
  in
    flatten (collectModules (extendModules {}).graph moduleType.getSubModules);

  mkRedundantAsserts = opt:
  let
    relevantModules = filter (m:
      hasAttrByPath (dropPrefix opt.loc) m.config && elem m.file opt.files
    ) collectedModules;

    modulesModule = { moduleType, ... }: {
      _module.args.modules =
        filter (m: any (m': m._file or m == m'.file) collectedModules)
          (subtractLists opt.type.getSubModules moduleType.getSubModules);
    };

    collectAsserts = v: v.assertions or
      (concatMap collectAsserts (if isAttrs v then attrValues v else v));
  in
    optionals (relevantModules != [] &&
      opt.loc != [ "system" "stateVersion" ] && #176295
      mkOverride opt.highestPrio {} != mkOptionDefault {}
    ) (
      if opt.visible or true == "shallow"
      || opt.type.getSubModules == null
      then
        forEach relevantModules (mkRedundantAssert opt)
      else
        collectAsserts ((opt.type.substSubModules (
          opt.type.getSubModules ++ [ modulesModule __curPos.file ]
        )).merge opt.loc opt.definitionsWithLocations)
    );
in

{
  options.assertions = mkOption {
    apply = v: builtins.parallel (catAttrs "assertion" v) v;
  };

  config.assertions =
    forEach config.warnings or []
      (message: { assertion = false; inherit message; }) ++
    concatMap mkRedundantAsserts
      (collect isOption (removeAttrs options [ "assertions" ]));
}
