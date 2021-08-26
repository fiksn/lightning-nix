{ config, pkgs, lib, ... }:
{
  hardware.enableRedistributableFirmware = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    loader = {
      grub.enable = false;
      # Silence the error
      grub.device = "nodev";
      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
  };

}
