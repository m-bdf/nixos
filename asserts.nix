{ config, lib, modulesPath, modules, extendModules, ... }@ self:

with lib;

let
  mkRedundantOptionWarning = module: paths: path:
  let
    removeAttrByPath = path: set:
      if length path == 1 then removeAttrs set path else set // {
        ${head path} = removeAttrByPath (tail path) set.${head path};
      };

    systemWithoutOption = extendModules {
      modules = singleton (module // {
        config = removeAttrByPath path module.config;
      });
    };

    defaultValue = attrByPath path id systemWithoutOption.config;
    actualValue = getAttrFromPath path module.config;
  in
    builtins.traceVerbose
      "Checking `${showAttrPath path}' in `${module._file}'…"

    optional (builtins.tryEval (actualValue == defaultValue)).value
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
      else if val ? _type then getOptionsPaths (pushDownProperties val)
      else concatLists
        (mapAttrsToList (k: v: map (p: [k] ++ p) (getOptionsPaths v)) val);

    optionsPaths = remove [ "system" "stateVersion" ] #176295
      (getOptionsPaths module.config);
  in
    concatMap (mkRedundantOptionWarning module optionsPaths) optionsPaths;

  userModules =
    filter (m: hasPrefix "${self}" m.key && m.key == m._file)
      (lib.modules.collectModules modulesPath modules (self // {
        pkgs = throw "Unhandled access to `pkgs' input in `${__curPos.file}'";
      }));
in

{
  assertions = map (message: { assertion = false; inherit message; })
    (config.warnings ++ concatMap mkRedundantOptionsWarnings userModules);
}
