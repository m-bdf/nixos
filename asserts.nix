{ config, lib, modules, extendModules, ... }@ inputs:

with lib;

let
  mkRedundantOptionWarning = module: paths: path:
  let
    filterByPaths = paths: set:
      foldl' (res: p:
        recursiveUpdate res (setAttrByPath p (getAttrFromPath p set))
      ) {} paths;

    systemWithoutOption = extendModules {
      modules = singleton (module // {
        config = filterByPaths (remove path paths) config;
      });
    };

    defaultValue = attrByPath path id systemWithoutOption.config;
    actualValue = getAttrFromPath path config;
    isRedundant =
      (builtins.tryEval defaultValue).success && actualValue == defaultValue;
  in
    builtins.traceVerbose
      "Checking `${showAttrPath path}' in `${module._file}'…"

    optional isRedundant
      "The option `${
        showAttrPath path
      }' is set in `${
        module._file
      }' to the redundant value `${
        generators.toPretty { multiline = false; } actualValue
      }'.";

  mkRedundantOptionsWarnings = module:
  let
    getOptionsPaths = val:
      if (builtins.tryEval (isAttrs val)).value -> val ? outPath then [[]]
      else if !(val ? _type) then concatLists
        (mapAttrsToList (k: v: map (p: [k] ++ p) (getOptionsPaths v)) val)
      else concatMap getOptionsPaths val.contents or
        (optional val.condition or true val.content);

    optionsPaths = remove [ "system" "stateVersion" ] #176295
      (getOptionsPaths module.config);
  in
    concatMap (mkRedundantOptionWarning module optionsPaths) optionsPaths;

  userModules =
    filter (m: elem m.key (map toString (catAttrs "_file" modules)))
      (lib.modules.collectModules "" modules (inputs // {
        pkgs = throw "Unhandled access to `pkgs' input in `${__curPos.file}'";
      }));
in

{
  assertions = map (message: { assertion = false; inherit message; })
    (config.warnings ++ concatMap mkRedundantOptionsWarnings userModules);
}
