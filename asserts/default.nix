{ _prefix, options, config, lib, modules, moduleType, extendModules, ... }@ args:

with lib;

let
  dropPrefix = drop (length _prefix);

  userModules =
  let
    evalFreeform = module:
      evalModules {
        specialArgs = args;
        modules = [ module rec {
          freeformType = with types;
            either (attrsOf freeformType) unspecified;
        }];
      };
  in
    flatten (zipListsWith (meta: module:
      optional (elem module modules) {
        inherit (meta) key file;
        inherit (evalFreeform module) options config;
        imports = catAttrs "file" (filter (m: m.key == m.file) meta.imports);
      }
    ) (extendModules {}).graph moduleType.getSubModules);

  mkAssertion = opt: m:
  let
    removeAttrByPath = path: set:
      if length path == 1 then removeAttrs set path
      else set // { ${head path} = removeAttrByPath (tail path) set.${head path}; };

    noDef = extendModules {
      modules = [{
        disabledModules = [m];
        options = removeAttrs m.options [ "_module" ];
        config = removeAttrByPath (dropPrefix opt.loc) m.config;
        inherit (m) imports;
      }];
    };

    pretty = generators.toPretty { multiline = false; }
      (getAttrFromPath (dropPrefix opt.loc) m.config);
  in
  {
    assertion = !(tryEval (getAttrFromPath (dropPrefix opt.loc) noDef.config == opt.value)).value;
    message = "The option `${showOption opt.loc}' is defined in `${m.file}' to the redundant value `${pretty}'.";
  };

  assertionsFor = opt:
  let
    flattenConfigs = v:
      if v ? configuration then [ v.configuration ]
      else concatMap flattenConfigs (flatten (attrValues (removeAttrs v [ "_internal" ])));

    relevant = filter (m:
      hasAttrByPath (dropPrefix opt.loc) m.config && elem m.file opt.files
    ) userModules;

    modulesModule = { moduleType, ... }: {
      _module.args.modules =
        filter (m: any (m': m._file or m == m'.file) userModules)
          (subtractLists opt.type.getSubModules moduleType.getSubModules);
    };
  in
    optionals (relevant != [] &&
      opt.loc != [ "system" "stateVersion" ] && #176295
      mkOverride opt.highestPrio {} != mkOptionDefault {}
    ) (
      if opt.visible or true == "shallow"
      || opt.type.getSubModules == null
      then map (mkAssertion opt) relevant
      else concatMap (c:
        (c.extendModules {
          modules = [ __curPos.file modulesModule ];
        }).config.assertions
      ) (flattenConfigs opt.valueMeta)
    );
in

{
  options.assertions = mkOption {};
  config.assertions =
    forEach config.warnings or []
      (message: { assertion = false; inherit message; }) ++
    concatMap assertionsFor
      (collect isOption (removeAttrs options [ "assertions" ]));
}
