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
in

{
  environment.binsh =
    pkgs.writeShellScript "sh" ''
      command_not_found_handle() {
        comma --picker ${pickLatest} "$@";
      }
      export -f command_not_found_handle
      exec "$BASH" "$@"
    '';

  home.programs = {
    zed-editor = {
      enableMcpIntegration = true;
      extensions = [ "mcp-server-sequential-thinking" ];

      userSettings = {
        language_models.opencode.show_zen_models = false;
        agent = {
          default_model = {
            provider = "opencode";
            model = "go/deepseek-v4-flash";
          };
          tool_permissions.default = "allow";
        };
      };
    };

    mcp = {
      enable = true;
      servers.NixOS.command = lib.getExe pkgs.mcp-nixos;
    };
  };
}
