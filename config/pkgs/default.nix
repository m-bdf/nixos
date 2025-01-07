{ inputs, lib, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];

  system.forbiddenDependenciesRegexes = lib.mkForce [];

  nixpkgs = {
    config = {
      warnUndeclaredOptions = true;

      allowAliases = false;
      allowUnfree = true;
      checkMeta = true;

      replaceStdenv = { pkgs }: pkgs.stdenv.override (prev: {
        mkDerivationFromStdenv =
          with builtins;
          with lib;
        let
          defaultMkDerivationFromStdenv = stdenv:
            (import /${pkgs.path}/pkgs/stdenv/generic/make-derivation.nix {
              inherit (pkgs) lib config;
            } stdenv).mkDerivation;

          extendMkDerivationArgs = prev: f: stdenv: args:
            (prev.mkDerivationFromStdenv or defaultMkDerivationFromStdenv
              stdenv args).overrideAttrs f;

          maybeEnable = args: attr: default:
            ifEnable (! elem args.pname or
              (parseDrvName (unsafeDiscardStringContext args.name)).name
              (splitString "\n" (readFile ./tmp/blacklist/${attr}.txt))
            ) args.${attr} or default;

          hasNoLegacyAttr = args:
            mutuallyExclusive (attrNames args) [
              "passAsFile"
              "allowedReferences" "disallowedReferences"
              "allowedRequisites" "disallowedRequisites"
            ];
        in #350350
          /*pkgs'.*/extendMkDerivationArgs prev
            (args: mapAttrs (maybeEnable args) {
              doCheck = true;
              doInstallCheck = true;
              strictDeps = true;
              __structuredAttrs = hasNoLegacyAttr args;
              enableParallelBuilding = true;
              configurePlatforms = [ "build" "host" ];
            });
      });
    }
    # //
    #   lib.genAttrs (lib.filter (lib.hasSuffix "ByDefault") (lib.attrNames
    #     inputs.nixpkgs.htmlDocs.nixpkgsManual.x86_64-linux.optionsDoc.optionsNix
    #   )) (opt: true)
    ;

    overlays = [
      (final: prev:
        lib.optionalAttrs (prev.config ? replaceStdenv) prev.pkgsZig.pkgsMusl // {
          substitute = args: (prev.substitute args).overrideAttrs { __structuredAttrs = false; };
          substituteAll = args: (prev.substituteAll args).overrideAttrs { __structuredAttrs = false; };
          buildRubyGem = args: (prev.buildRubyGem args).overrideAttrs { __structuredAttrs = false; };
        }
      )
    ];
  };
}
