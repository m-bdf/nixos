{ inputs, lib, pkgs, ... }:

let
  languess = pkgs.writeScript "languess" ''
    #!${lib.getExe pkgs.bun}

    import hljs from '${inputs.highlightjs}';

    const code = await Bun.stdin.text();
    console.log(code);

    try {
      JSON.parse(code);
      console.warn('json');
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
      sed 's|{LANGUESS}|${languess}|' ${./highlight.rs} >> src/assets.rs

      sed -i src/assets.rs -e '/\[unknown\]/ s/Err/ \
        self.get_syntax_for_file_contents(\&mut input.reader)?.ok_or/'

      sed -i src/controller.rs -e 's/fn print_file_ranges/pub(crate) &/'
    '';
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
