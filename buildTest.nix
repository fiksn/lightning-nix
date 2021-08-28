{ hostname ? "", flakePath ? /etc/nixos, pkgs ? import <nixpkgs> { }, ... }:
let
  lib = pkgs.lib;
  flake = builtins.getFlake (toString flakePath);
  allUsers =
    if hostname != "" then flake.nixosConfigurations.${hostname}.config.users
    else
      (builtins.concatMap (c: flake.nixosConfigurations.${c}.config.users) (lib.attrNames flake.nixosConfigurations));
in
allUsers
