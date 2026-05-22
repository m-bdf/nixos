{ lib, pkgs, ... }:

let
  pickLatest = pkgs.writeShellScript "pick-latest" ''
    while read pkg; do
      nix derivation show nixpkgs#"$pkg" 2>/dev/null |
      ${lib.getExe pkgs.jaq} --arg pkg "$pkg" \
        '.derivations[] | .structuredAttrs // .env
        | select(.name == .pname + "-" + .version)
        | [$pkg, .version]' --to tsv &
    done | sort -k2Vr | head -1 | cut -f1
  '';
in

{
  programs.bash.interactiveShellInit = ''
    if [ -n "$CURSOR_AGENT" ]; then
      command_not_found_handle() {
        comma --picker ${pickLatest} "$@"
      }
    fi
  '';

  home.home.file = lib.concatMapAttrs (n: v: {
    ".cursor/${n}.json".text = lib.toJSON v;
  }) {
    mcp.mcpServers = {
      nix = {
        command = lib.getExe pkgs.mcp-language-server;
        args = [ "--workspace" "\${workspaceFolder}" "--lsp" "nixd" ];
      };
      nixos.command = lib.getExe pkgs.mcp-nixos;
    };
    permissions.mcpAllowlist = [ "*:*" ];
  };
}
