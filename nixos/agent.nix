{ lib, pkgs, ... }:

let
  pickLatest = pkgs.writeShellScript "pick-latest" ''
    while read pkg; do
      nix derivation show nixpkgs#"$pkg" |
      ${lib.getExe pkgs.jaq} --arg pkg "$pkg" \
        '.derivations[] | .structuredAttrs // .env
        | select(.name == .pname + "-" + .version)
        | [$pkg, .version]' --to tsv &
    done 2>/dev/null |
    sort -k2Vr | head -1 | cut -f1
  '';

  runCmdline = pkgs.writeShellScript "run-cmdline" ''
    command_not_found_handle() {
      comma --picker ${pickLatest} "$@"
    }

    remove_absolute_path() {
      for w; do
        [[ $w =~ ^/[/[:alnum:]+]+$ ]] &&
        eval "$w() { command ''${w##*/}" '"$@"; }'
      done
    }

    set -T && trap '
      eval remove_absolute_path "$BASH_COMMAND"
    ' DEBUG && eval "$1"
  '';
in

{
  home.programs.fish.shellInit = ''
    set -q CURSOR_AGENT && exec ${runCmdline} \
      (string split0 -f3 </proc/$fish_pid/cmdline)
  '';

  home.home.file.".cursor/mcp.json".text = lib.toJSON {
    mcpServers = {
      nix = {
        command = lib.getExe pkgs.mcp-language-server;
        args = [ "--workspace" "\${workspaceFolder}" "--lsp" "nixd" ];
      };
      nixos.command = lib.getExe pkgs.mcp-nixos;
    };
  };
}
