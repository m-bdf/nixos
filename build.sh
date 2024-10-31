#!/bin/sh

sudo nixos-rebuild build --flake $(readlink -f /etc/nixos)#minimal --accept-flake-config --impure
