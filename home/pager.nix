{ lib, pkgs, ... }:

let
  languess = pkgs.writeText "languess.go" ''
    runParserCmd :=
      func(name string, args ...string) string {
        cmd := exec.Command(name, args...)
        cmd.Stdin = bytes.NewBufferString(text)
        stdout, _ := cmd.Output()
        return strings.TrimSpace(string(stdout))
      }

    if language == "" && !strings.Contains(text, "\x1B") {
      if runParserCmd("nix-instantiate", "--parse", "-") != "" {
        language = "nix"
      } else {
        const MAGIKA = "${lib.getExe pkgs.magika-cli}"
        language = runParserCmd(MAGIKA, "--format", "%l", "-")
      }
    }
  '';

  moor = pkgs.moor.overrideAttrs {
    patchPhase = ''
      sed -i '/import/a "os/exec"
        /GetLanguage/r ${languess}
      ' internal/reader/highlight.go
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
