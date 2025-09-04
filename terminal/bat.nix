{ inputs, lib, pkgs, ... }:

let
  highlightjs = pkgs.buildNpmPackage (final: {
    name = "highlight.js";
    src = inputs.highlightjs;

    npmDeps = pkgs.importNpmLock { npmRoot = final.src; };
    inherit (pkgs.importNpmLock) npmConfigHook;

    installPhase = "mv build $out";
  });

  bat = pkgs.writers.writeJSBin "bat" {} ''
    process.title = 'bat';

    const bat = '${lib.getExe pkgs.bat}';
    const argv = process.argv.slice(2);
    if (argv[0] === 'cache')
      process.execve(bat, [ bat, ...argv ], process.env);

    const { spawnSync } = require('child_process');
    const input = spawnSync(bat, [ '--plain', ...argv ],
      { stdio: [ 'inherit' ], encoding: 'utf8' }).stdout;

    const hl = require('${highlightjs}').highlightAuto(input);
    const exec = (lang, stderr) =>
      spawnSync(bat, [ '--language', lang, ...argv ],
        { stdio: [ 'pipe', 'inherit', stderr ], input }).status;

    if (exec(hl.language) === 0) return;
    if (exec(hl.secondBest.language) === 0) return;
    process.exit(exec('Plain Text', 'inherit'));
  '';
in

{
  programs.bat = {
    enable = true;
    package = bat;
    config = {
      style = "plain";
      theme = "GitHub Dark";
    };
    themes.github.src = inputs.github-textmate-theme;
  };
}
