{ inputs, lib, pkgs, ... }:

let
  languess = pkgs.writeScript "languess.js" ''
    #!${lib.getExe pkgs.bun}
    import hljs from '${inputs.highlightjs}';

    const result = hljs.highlightAuto(await Bun.stdin.text());
    const first = hljs.getLanguage(result.language);
    const second = hljs.getLanguage(result.secondBest.language);

    console.log(first?.name ?? ''', ...first?.aliases ?? []);
    console.log(second?.name ?? ''', ...second?.aliases ?? []);
  '';

  exec-languess = pkgs.writeText "languess.go" ''
    if !strings.Contains(text, "\x1B") {
      cmd := exec.Command("${languess}")
      cmd.Stdin = bytes.NewBufferString(text)

      stdout, err := cmd.Output()
      if err != nil {
        log.Warn(err)
        return
      }

      guesses := strings.Fields(string(stdout))
      for _, guess := range guesses {
        options.Lexer = lexers.Get(guess)
        if options.Lexer != nil {
          log.Info("Guessed lexer: ", guess)
          break
        }
      }
    }
  '';

  moor = pkgs.moor.overrideAttrs {
    patchPhase = ''
      sed -i '/import/a "os/exec"
        /No lexer/{ r ${exec-languess}
          a }\n if options.Lexer == nil {
        }' internal/reader/highlight.go
    '';
  };
in

{
  home = {
    packages = [ moor ];
    sessionVariables = {
      PAGER = "moor";
      MOOR = toString [
        "-reformat"
        "-style github-dark"
        "-quit-if-one-screen"
      ];
    };
  };
}
