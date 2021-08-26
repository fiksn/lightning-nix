{ config, pkgs, lib, ... }:
{
  imports = [
    ../blockchain-services.nix
    ../rpi.nix
  ];

  services.node-storage = {
    mountPath = "/storage";
    externalDrive = false;
  };

  fileSystems = {
    "/" = {
      fsType = "ext4";
      device = "/dev/disk/by-label/data";
    };
    "/boot" = {
      fsType = "vfat";
      device = "/dev/disk/by-uuid/A4CD-9C10";
    };
  };

  local-ci.enable = true;

  networking.useDHCP = true;

  services.rtl.listenHost = "0.0.0.0";
  networking.firewall.allowedTCPPorts = [ 9735 10009 8080 3000 ];
}
