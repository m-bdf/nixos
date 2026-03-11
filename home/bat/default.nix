{ inputs, lib, pkgs, ... }:

let
  languess = pkgs.writeScript "languess" ''
    #!${lib.getExe pkgs.bun}

    import hljs from '${inputs.highlightjs}';

    const code = await Bun.stdin.text();
    await Bun.stdout.write(code);

    try {
      if (!code.includes('\x1B')) {
        JSON.parse(code);
        console.warn('json');
      }
    }

    catch {
      const result = hljs.highlightAuto(code.substring(0, Buffer.poolSize));
      const first = hljs.getLanguage(result.language);
      const second = hljs.getLanguage(result.secondBest.language);

      console.warn(first?.name ?? ''', ...first?.aliases ?? []);
      console.warn(second?.name ?? ''', ...second?.aliases ?? []);
    }
  '';

  bat = pkgs.bat.overrideAttrs (prev: {
    pname = prev.pname + "-highlight";
    patchPhase = ''
      sed -i 's/\.get_first_line/\.get_contents/' src/assets.rs
      sed 's|{LANGUESS}|${languess}|' ${./highlight.rs} >> src/assets.rs
      sed -i '/struct InputReader/a pub(crate)' src/input.rs
    '';
    checkFlags = prev.checkFlags ++ [ "--skip=ignored_suffix_arg" ];
  });
in

{
  programs.bat = {
    enable = true;
    package = bat;
    config = {
      style = "plain";
      theme = "GitHub Dark";
    };
    themes."GitHub Dark" = {
      src = inputs.github-textmate-theme;
      file = "GitHub Dark.tmTheme";
    };
  };

  home.sessionVariables.PAGER = "bat";
}
