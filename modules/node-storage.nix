{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.node-storage;
in
{
  options.services.node-storage = {
    mountPath = mkOption {
      type = types.path;
      example = "/storage";
      description = "The mount path for storage";
    };
    externalDrive = mkEnableOption {
      type = types.bool;
      example = true;
      description = "Is it an external drive";
    };
  };

  config = mkIf cfg.externalDrive {
    systemd.services.bitcoin-secrets.preStart = "${pkgs.utillinux}/bin/mountpoint -q -- ${cfg.mountPath}";
  };
}
