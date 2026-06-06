{ inputs, lib, pkgs, ... }:

let
  addons = {
    inherit (pkgs.firefox-addons)
      darkreader ublock-origin bitwarden;
  };
in

{
  nixpkgs.overlays = [ inputs.firefox-addons.overlays.default ];

  home.programs.zen-browser = {
    policies.ExtensionSettings =
      lib.concatMapAttrs (name: addon: {
        ${addon.addonId} = {
          install_url = "file:${addon.src}";
          installation_mode = "force_installed";
          default_area = "navbar";
          private_browsing = true;
        };
      }) addons;

    profiles.default = {
      settings."extensions.webextensions.uuids" =
        lib.concatMapAttrs (name: addon: {
          ${addon.addonId} = addon.src.outputHash;
        }) addons;

      extensions.settings = {
        ${addons.darkreader.addonId} = {
          settings = {
            syncSettings = false;
            previewNewDesign = true;
            previewNewestDesign = true;
            fetchNews = false;
          };
          force = true;
        };
      };
    };
  };
}
